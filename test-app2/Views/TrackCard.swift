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
    @State var play = false
    
    // Audio player
    @State var audioPlayer: AVPlayer?
    @State var itemDidPlayToEndTimeObserver: NSObjectProtocol?
    @State var itemFailedToPlayToEndTimeObserver: NSObjectProtocol?
    @State var itemPlaybackStalledObserved: NSObjectProtocol?

    @State private var progress = 0.0
    
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
                
                if let audioPlayer = audioPlayer,
                   audioPlayer.timeControlStatus == .playing {
                    ProgressView(value: progress)
                        .padding([.horizontal], spotifyLogoHeight / 2)
                        
                        // .border(.red)
       
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
                    Image(systemName: play == true && model.playingTrackID == track.id ? "pause.fill" : "play.fill")
                        .foregroundColor(
                            Color(.sRGB,
                                  red: Double(186) / 255,
                                  green: Double(186) / 255,
                                  blue: Double(186) / 255,
                                  opacity: 1)
                        
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded {
                                    if let audioPlayer = audioPlayer {
                                        if play == false {
                                            audioPlayer.play()
                          
                                            withAnimation(.easeIn(duration: 0.1)) {
                                                play = true
                                                model.playingTrackID = track.id
                                            }
                                            
                                        } else {
                                            audioPlayer.pause()
                                            withAnimation(.easeIn(duration: 0.1)) {
                                                play = false
                                            }
                                        }
                                        
                                    }
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
        .onAppear {
            print("disapp")
//            APICaller.shared.checkUsersSavedTrack(trackID: track.id) { result in
//                like = result
//                
//            }
//
//            // initalize AVPlayer
//            if let urlString = track.preview_url,
//               let url = URL(string: urlString) {
//                audioPlayer = AVPlayer(url: url)
//                audioPlayer!.actionAtItemEnd = .pause
//                audioPlayer!.addPeriodicTimeObserver(forInterval:
//                                                        CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
//                                                     queue: .main,
//                                                     using: { time in
//                    // weird problem here, starts at 0 and jump to 0.1
//                     print(time.seconds)
//                    progress = time.seconds / 30
//                })
//
//                // add oberver to detect when preview ends
//                itemDidPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: audioPlayer!.currentItem, queue: .main) { _ in
//                    // seek to beginning
//                    print("pp:")
//                    audioPlayer?.pause()
//                    audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
//
//                }
//
//                itemFailedToPlayToEndTimeObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemFailedToPlayToEndTime, object: audioPlayer!.currentItem, queue: .main) { _ in
//                    // seek to beginning
//                    print("pp:x")
//                    audioPlayer?.pause()
//                    audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
//
//                }
//
//                itemPlaybackStalledObserved = NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: audioPlayer!.currentItem, queue: .main) { _ in
//                    // seek to beginning
//                    print("pp:")
//                    audioPlayer?.pause()
//                    audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
//
//                }
//
//
//
//            }
        }
        .onDisappear {
//            print("dis")
//            play = false
//            audioPlayer?.pause()
//            audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
//
//            NotificationCenter.default.removeObserver(itemDidPlayToEndTimeObserver!)
//            NotificationCenter.default.removeObserver(itemFailedToPlayToEndTimeObserver!)
//            NotificationCenter.default.removeObserver(itemPlaybackStalledObserved!)
//
            
            
        }
        .onReceive(model.$playingTrackID) { id in
//            guard let trackID = id else {
//                return
//            }
//
//            if track.id != trackID && audioPlayer?.timeControlStatus == .playing {
//                // stop playing and seek to beginning
//                play = false
//                audioPlayer?.pause()
//                audioPlayer?.seek(to: CMTime(seconds: 0, preferredTimescale: 30))
//            }

        }
        
        .onChange(of: scenePhase) { phase in
            // check .inactive
//            if phase == .background {
//                // pause the player if it's playing when app goes to background
//                if play == true {
//                    audioPlayer?.pause()
//                }
//            } else if phase == .active {
//                // continue playing if the player was paused
//                if play == true {
//                    audioPlayer?.play()
//                }
//            }
        }

    }
}



/*
 struct TrackCard_Previews: PreviewProvider {
     static var previews: some View {
         TrackCard()
     }
 }
 */
