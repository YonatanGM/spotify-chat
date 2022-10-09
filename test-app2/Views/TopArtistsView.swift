//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit



// horizontal scrollable view of the artists
struct TopArtistsView: View {
    @EnvironmentObject var model: AppStateModel
    var artists: [Artist]
    @State var selectedTrackID: String?
    @State var isTapping: Bool = false
    

    
    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 30) {
                ForEach(artists, id: \.id) { artist in
                    ArtistCard(artist: artist)
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

