//
//  TrackCard.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.09.22.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFAudio

import AVKit

struct TrackCard: View {
    @EnvironmentObject var model: AppStateModel
    @Environment(\.scenePhase) private var scenePhase
    let track: Track
    @State var isTapping: Bool = false
    // @State var isAnimating: Bool = false
    @State var likeUnlikeMessage: String?
    var spotifyLogoHeight: CGFloat = 20
    @State var cardHeight: CGFloat?
    var body: some View {
        
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                if let urlString = track.album?.images.first?.url,
                   let url = URL(string: urlString) {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .frame(width: Double(UIScreen.main.bounds.width) / 1.75,
                               height: Double(UIScreen.main.bounds.width) / 1.75)
                } else {
                    // probably don't need this
                    Image(systemName: "Rectangle.fill")
                        .padding(5)
                        .foregroundColor(
                            Color(.sRGB,
                                  red: Double(24) / 255,
                                  green: Double(24) / 255,
                                  blue: Double(24) / 255,
                                  opacity: 1)
                        )
                }
                TrackMetadata(track: track)
            }
            .frame(width: Double(UIScreen.main.bounds.width) / 1.75)
            .padding([.horizontal, .top], spotifyLogoHeight / 2)
            
            // spotify logo, audio control and like button
            VStack(alignment: .leading, spacing: 0) {
                if model.playingTrackID == track.id && model.progress > 0.0 {
                    ProgressView(value: model.progress)
                        .padding([.horizontal, .top], spotifyLogoHeight / 2)
                        .accentColor(.white)
 
                }
                if let message = likeUnlikeMessage {
                    Text(message)
                        .foregroundColor(.white.opacity(0.75))
                        .font(.caption2)
                        .padding([.horizontal, .top], spotifyLogoHeight / 2)
                }
                HStack {
                    Image("rsz_1spotify_logo_rgb_white")
                        .resizable()
                        .scaledToFit()
                        .frame(height: spotifyLogoHeight)
                    Spacer()
                    Image(systemName: model.likedTracks[track.id] == true ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    if let isLiked = model.likedTracks[track.id] {
                                        if !isLiked {
                                            APICaller.shared.addToLikedSongs(trackID: track.id) { successfullyAddedToLikedSongs in
                                                if successfullyAddedToLikedSongs {
                                                    DispatchQueue.main.async {
                                                        model.likedTracks[track.id] = true
                                                        withAnimation(.easeIn(duration: 0.2)) {
                                                            likeUnlikeMessage = "Added to Liked Songs"
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                            withAnimation(.easeIn(duration: 0.2)) {
                                                                likeUnlikeMessage = nil
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            APICaller.shared.removeFromLikedSongs(trackID: track.id) { successfullyRemovedFromLikedSongs in
                                                if successfullyRemovedFromLikedSongs {
                                                    DispatchQueue.main.async {
                                                        model.likedTracks[track.id] = false
                                                        withAnimation(.easeIn(duration: 0.2)) {
                                                            likeUnlikeMessage = "Removed from Liked Songs"
                                                        }
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                            withAnimation(.easeIn(duration: 0.2)) {
                                                                likeUnlikeMessage = nil
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                    )
                    .foregroundColor(
                        model.likedTracks[track.id] == true ?
                            .white:
                        Color(.sRGB,
                              red: Double(186) / 255,
                              green: Double(186) / 255,
                              blue: Double(186) / 255,
                              opacity: 1)
                    )
                    .opacity(model.likedTracks[track.id] != nil ? 1 : 0)
                    
                    Image(systemName: model.play == true && model.playingTrackID == track.id ? "pause.fill" : "play.fill")
                        .foregroundColor(
                            Color(.sRGB,
                                  red: Double(186) / 255,
                                  green: Double(186) / 255,
                                  blue: Double(186) / 255,
                                  opacity: 1)
                        
                        )
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    model.handlePlayback(of: track)
                                }
                        )
                }
                // logo exclusion zone from top
                .padding(spotifyLogoHeight / 2)
                

            }
        }
        .animation(.easeIn(duration: 0.2), value: model.playingTrackID == track.id && model.progress > 0.0)
        .background(.white.opacity(0.05))
        .cornerRadius(5)
        .scaleEffect(model.selectedTrackID == track.id && isTapping ? 0.9 : 1)
        .brightness(model.selectedTrackID == track.id && isTapping ? 0.1 : 0)
        .onTapGesture {
            model.selectedTrackID = track.id
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                    
                }

            }
            if let url = URL(string: track.external_urls["spotify"]!) {
                UIApplication.shared.open(url) { _ in
                    
                }
            }
    
        }
        
        .onAppear {
            if model.likedTracks[track.id] == nil {
                // api call
                APICaller.shared.checkIfUserHasSavedTracks(with: [track.id]) { result in
                    switch result {
                    case .success(let dict):
                        DispatchQueue.main.async {
                            model.likedTracks[track.id] = dict[track.id]
                        }
                    case .failure(let error):
                        print("couldn't check if user has saved track \(track.id): \(error.localizedDescription)")
                    }
                     
                }
                
            }
        }

    }
}

