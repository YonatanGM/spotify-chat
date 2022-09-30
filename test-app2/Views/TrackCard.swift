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
    @State var like = false
    var spotifyLogoHeight: CGFloat = 20
    var body: some View {
        
        VStack(spacing: 0) {
            VStack {
                if let urlString = track.album?.images.first?.url,
                   let url = URL(string: urlString) {
                     AnimatedImage(url: url)
                    // Image(systemName: "Rectangle.fill")
                        .resizable()
                        .scaledToFit()
                
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
            
                HStack {
                    
                    VStack(alignment: .leading) {
                        Text(track.name)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(track.artists.map {$0.name}.joined(separator: ", "))
                            .font(.caption2)
                            .foregroundColor(
                                Color(.sRGB,
                                      red: Double(167) / 255,
                                      green: Double(167) / 255,
                                      blue: Double(167) / 255,
                                      opacity: 1)
                            )
                            .fixedSize(horizontal: false, vertical: true)
                    
                    }
                    
                    Spacer()
                }
            }
            .frame(height: Double(UIScreen.main.bounds.width) / 1.5)
            .padding(spotifyLogoHeight / 2)
            // .border(.red)
            // spotify logo, audio control and like button
            VStack(spacing: 0) {
                if model.playingTrackID == track.id && model.progress > 0.0 {
                    ProgressView(value: model.progress)
                        .padding([.horizontal], spotifyLogoHeight / 2)
                }
                HStack {
                    Image("rsz_1spotify_logo_rgb_white")
                        .resizable()
                        .scaledToFit()
                        .frame(height: spotifyLogoHeight)
                    Spacer()
                    Image(systemName: like ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    if like == false {
                                        APICaller.shared.addToLikedSongs(trackID: track.id) { result in
                                            if result == true {
                                                withAnimation(.easeIn(duration: 0.1)) {
                                                    like = true
                                                }
                                            }
                                        }
                                    } else {
                                        APICaller.shared.removeFromLikedSongs(trackID: track.id) { result in
                                            if result == true {
                                                withAnimation(.easeIn(duration: 0.1)) {
                                                    like = false
                                                }
                                            }
                                        }
                                    }
                                }
                    )
                
                    .foregroundColor(
                        like ?
                            .white:
                        Color(.sRGB,
                              red: Double(186) / 255,
                              green: Double(186) / 255,
                              blue: Double(186) / 255,
                              opacity: 1)
                    )
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
                // .border(.red)
            }
            // .border(.blue)
        }
        .background(
            Color(.sRGB,
                  red: 1,
                  green: 1,
                  blue: 1,
                  opacity: 0.05)
        )
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

    }
}

