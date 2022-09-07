//
//  TrackCard.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrackCard: View {
    @EnvironmentObject var model: AppStateModel
    let track: Track
    @State var isTapping: Bool = false
    @State var like = false
    
    
    var body: some View {
        
        VStack {

            
            VStack {
                if let urlString = track.album?.images.first?.url,
                   let url = URL(string: urlString) {
                    AnimatedImage(url: url)
                        .resizable()
                        .scaledToFill()
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
                
                HStack {
                   
                    
                    Image("rsz_1spotify_logo_rgb_white")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 20)
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
                    Image(systemName: "play.fill")
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
                                    print("Tap on VStack.")
                                }
                                
                        )
                }
                Spacer()
            }
            .padding([.top, .horizontal])
            .padding([.bottom], 5)
        }
        .frame(height: Double(UIScreen.main.bounds.width) / 1.25)
        .background(
            Color(.sRGB,
                  red: Double(24) / 255,
                  green: Double(24) / 255,
                  blue: Double(24) / 255,
                  opacity: 0.75)
        )
        .cornerRadius(5)
        .scaleEffect(model.selectedTrackID == track.id && isTapping ? 0.97 : 1)
        .brightness(model.selectedTrackID == track.id && isTapping ? 0.05 : 0)
        
        .onTapGesture {
            model.selectedTrackID = track.id
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
            }
    
        }
        .onAppear {
            APICaller.shared.checkUsersSavedTrack(trackID: track.id) { result in
                like = result
                
            }
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
