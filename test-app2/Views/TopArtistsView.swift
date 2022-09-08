//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit



// horizontal scrollable view of the artists following spotify developer guideline
struct TopArtistsView: View {
    @EnvironmentObject var model: AppStateModel
    // @State var topArtistResponse: TopArtistsResponse?
    @State var selectedTrackID: String?
    @State var isTapping: Bool = false
    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            if let topArtistResponse = model.usersInCurrentRoom.first?.topArtists {
                HStack {
                    ForEach(topArtistResponse.items, id: \.id) { artist in
                        
                        if let urlString = artist.images?.first?.url,
                           let url = URL(string: urlString) {
                            
                            ZStack {
//                                Color(.sRGB,
//                                      red: Double(24) / 255,
//                                      green: Double(24) / 255,
//                                      blue: Double(24) / 255,
//                                      opacity: 1)
                                VStack {
                                    
                                    HStack {
                                        Spacer()
                                        Image("Spotify_Icon_RGB_Green")
                                            
                                            .resizable()
                                            .scaledToFill()
                                        
                                            .frame(width: 15, height: 15)
                                            .opacity(0)
                                            
                                            
                                    }
                                    AnimatedImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                    
                                    HStack {
                                        
                                        VStack(alignment: .leading) {
                                            Text(artist.name)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            Text("Artist")
                                                .font(.caption2)
                                                .foregroundColor(
                                                    Color(.sRGB,
                                                          red: Double(167) / 255,
                                                          green: Double(167) / 255,
                                                          blue: Double(167) / 255,
                                                          opacity: 1))
                                                .fixedSize(horizontal: false, vertical: true)
                                        
                                        }
                                        Spacer()
                                    }
                                        
                                }
                                .padding(5)
                                .padding([.bottom], 5)
                                
                            }
                            .cornerRadius(5)
                            .scaleEffect(selectedTrackID == artist.id && isTapping ? 0.97 : 1)
                            .brightness(selectedTrackID == artist.id && isTapping ? 0.05 : 0)
                            
                            .onTapGesture {
                                selectedTrackID = artist.id
                                // animation
                                withAnimation(.easeIn(duration: 0.1)) {
                                    isTapping = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        isTapping = false
                                    }
                                }
                                
                                // Open spotify
                                if let url = URL(string: artist.external_urls["spotify"]!) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        
                        }
                    }
                }
            }

        }
        .frame(height: Double(UIScreen.main.bounds.width) / 2)

    }
}

struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView()
    }
}
