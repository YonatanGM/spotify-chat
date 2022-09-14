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

                LazyHStack {
                    ForEach(topArtistResponse.items, id: \.id) { artist in
                        
                        if let urlString = artist.images?.first?.url,
                           let url = URL(string: urlString) {
                                VStack {
                                    AnimatedImage(url: url)
                                        .resizable()
                                        .scaledToFill()
                                        .clipShape(Circle())
                                        .frame(height: Double(UIScreen.main.bounds.width) / 3)
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text(artist.name)
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        
                                        }
                                        Spacer()
                                    }
                                    Spacer()
                                        
                                }
                                .padding(5)
                                .cornerRadius(5)
                                .scaleEffect(selectedTrackID == artist.id && isTapping ? 0.9 : 1)
                                .brightness(selectedTrackID == artist.id && isTapping ? 0.1 : 0)
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
                                        // open spotify
                                        if let url = URL(string: artist.external_urls["spotify"]!) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                   
                                }
                                
                        }
                    }
                }
            }

        }

    }
}

struct TopTracksView_Previews: PreviewProvider {
    static var previews: some View {
        TopTracksView()
    }
}
