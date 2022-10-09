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
                HStack(alignment: .center) {
                    Image("rsz_1spotify_logo_rgb_white")
                        .resizable()
                        .scaledToFit()
                        .frame(height: spotifyLogoHeight)
                    Spacer()
                    getSpotifyHeartIcon(liked: model.likedTracks[track.id] == true, in: CGSize(width: 15, height: 15))
                        .frame(width: 15, height: 15)
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
                    .foregroundColor(.white.opacity(0.75))
                    .opacity(model.likedTracks[track.id] != nil ? 1 : 0)
                    
                    Image(systemName: model.play == true && model.playingTrackID == track.id ? "pause.fill" : "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13, height: 13)
                        .foregroundColor(.white.opacity(0.75))
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    model.handlePlayback(of: track)
                                }
                        )
                }
//                .border(.red)
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


extension TrackCard {

    var spotifyUnlikedHeartIcon: Path {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 91.68, y: 9.26))
        bezierPath.addCurve(to: CGPoint(x: 53.39, y: 7.51), controlPoint1: CGPoint(x: 81.22, y: -1.19), controlPoint2: CGPoint(x: 64.77, y: -1.95))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 8.72), controlPoint1: CGPoint(x: 53.38, y: 7.52), controlPoint2: CGPoint(x: 51.91, y: 8.72))
        bezierPath.addCurve(to: CGPoint(x: 46.61, y: 7.5), controlPoint1: CGPoint(x: 48.06, y: 8.72), controlPoint2: CGPoint(x: 46.66, y: 7.54))
        bezierPath.addCurve(to: CGPoint(x: 8.33, y: 9.26), controlPoint1: CGPoint(x: 35.25, y: -1.95), controlPoint2: CGPoint(x: 18.79, y: -1.19))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 29.36), controlPoint1: CGPoint(x: 2.96, y: 14.63), controlPoint2: CGPoint(x: 0, y: 21.77))
        bezierPath.addCurve(to: CGPoint(x: 8.23, y: 49.35), controlPoint1: CGPoint(x: 0, y: 36.95), controlPoint2: CGPoint(x: 2.96, y: 44.09))
        bezierPath.addLine(to: CGPoint(x: 41.23, y: 87.96))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 92), controlPoint1: CGPoint(x: 43.43, y: 90.53), controlPoint2: CGPoint(x: 46.63, y: 92))
        bezierPath.addCurve(to: CGPoint(x: 58.78, y: 87.96), controlPoint1: CGPoint(x: 53.39, y: 92), controlPoint2: CGPoint(x: 56.58, y: 90.53))
        bezierPath.addLine(to: CGPoint(x: 91.68, y: 49.46))
        bezierPath.addCurve(to: CGPoint(x: 91.68, y: 9.26), controlPoint1: CGPoint(x: 102.77, y: 38.38), controlPoint2: CGPoint(x: 102.77, y: 20.34))
        bezierPath.close()
        bezierPath.move(to: CGPoint(x: 88.86, y: 46.85))
        bezierPath.addLine(to: CGPoint(x: 55.86, y: 85.46))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 88.16), controlPoint1: CGPoint(x: 54.39, y: 87.17), controlPoint2: CGPoint(x: 52.26, y: 88.16))
        bezierPath.addCurve(to: CGPoint(x: 44.16, y: 85.46), controlPoint1: CGPoint(x: 47.75, y: 88.16), controlPoint2: CGPoint(x: 45.62, y: 87.17))
        bezierPath.addLine(to: CGPoint(x: 11.05, y: 46.74))
        bezierPath.addCurve(to: CGPoint(x: 3.85, y: 29.36), controlPoint1: CGPoint(x: 6.41, y: 42.1), controlPoint2: CGPoint(x: 3.85, y: 35.93))
        bezierPath.addCurve(to: CGPoint(x: 11.05, y: 11.98), controlPoint1: CGPoint(x: 3.85, y: 22.79), controlPoint2: CGPoint(x: 6.41, y: 16.62))
        bezierPath.addCurve(to: CGPoint(x: 28.45, y: 4.73), controlPoint1: CGPoint(x: 15.87, y: 7.17), controlPoint2: CGPoint(x: 22.15, y: 4.73))
        bezierPath.addCurve(to: CGPoint(x: 44.1, y: 10.41), controlPoint1: CGPoint(x: 33.98, y: 4.73), controlPoint2: CGPoint(x: 39.53, y: 6.61))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 12.57), controlPoint1: CGPoint(x: 44.34, y: 10.63), controlPoint2: CGPoint(x: 46.61, y: 12.57))
        bezierPath.addCurve(to: CGPoint(x: 55.86, y: 10.45), controlPoint1: CGPoint(x: 53.31, y: 12.57), controlPoint2: CGPoint(x: 55.63, y: 10.65))
        bezierPath.addCurve(to: CGPoint(x: 88.96, y: 11.98), controlPoint1: CGPoint(x: 65.69, y: 2.28), controlPoint2: CGPoint(x: 79.92, y: 2.94))
        bezierPath.addCurve(to: CGPoint(x: 88.86, y: 46.85), controlPoint1: CGPoint(x: 98.55, y: 21.56), controlPoint2: CGPoint(x: 98.55, y: 37.16))
        bezierPath.close()

        return Path(bezierPath.cgPath)
    }
    
    var spotifyLikedHeartIcon: Path {
        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 91.68, y: 9.26))
        bezierPath.addCurve(to: CGPoint(x: 53.39, y: 7.51), controlPoint1: CGPoint(x: 81.22, y: -1.19), controlPoint2: CGPoint(x: 64.77, y: -1.95))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 8.72), controlPoint1: CGPoint(x: 53.38, y: 7.52), controlPoint2: CGPoint(x: 51.91, y: 8.72))
        bezierPath.addCurve(to: CGPoint(x: 46.61, y: 7.5), controlPoint1: CGPoint(x: 48.06, y: 8.72), controlPoint2: CGPoint(x: 46.66, y: 7.54))
        bezierPath.addCurve(to: CGPoint(x: 8.33, y: 9.26), controlPoint1: CGPoint(x: 35.25, y: -1.95), controlPoint2: CGPoint(x: 18.79, y: -1.19))
        bezierPath.addCurve(to: CGPoint(x: 0, y: 29.36), controlPoint1: CGPoint(x: 2.96, y: 14.63), controlPoint2: CGPoint(x: 0, y: 21.77))
        bezierPath.addCurve(to: CGPoint(x: 8.23, y: 49.35), controlPoint1: CGPoint(x: 0, y: 36.95), controlPoint2: CGPoint(x: 2.96, y: 44.09))
        bezierPath.addLine(to: CGPoint(x: 41.23, y: 87.96))
        bezierPath.addCurve(to: CGPoint(x: 50.01, y: 92), controlPoint1: CGPoint(x: 43.43, y: 90.53), controlPoint2: CGPoint(x: 46.63, y: 92))
        bezierPath.addCurve(to: CGPoint(x: 58.78, y: 87.96), controlPoint1: CGPoint(x: 53.39, y: 92), controlPoint2: CGPoint(x: 56.58, y: 90.53))
        bezierPath.addLine(to: CGPoint(x: 91.68, y: 49.46))
        bezierPath.addCurve(to: CGPoint(x: 91.68, y: 9.26), controlPoint1: CGPoint(x: 102.77, y: 38.38), controlPoint2: CGPoint(x: 102.77, y: 20.34))
        bezierPath.close()
        return Path(bezierPath.cgPath)
    }
    
    func getSpotifyHeartIcon(liked: Bool, in frame: CGSize) -> Path {
        return liked ? spotifyLikedHeartIcon.applying(CGAffineTransform(scaleX: frame.width / 100 , y: frame.height / 100)) : spotifyUnlikedHeartIcon.applying(CGAffineTransform(scaleX: frame.width / 100 , y: frame.height / 100))
    }
}
