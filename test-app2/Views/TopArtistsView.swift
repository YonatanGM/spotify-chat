//
//  TopView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 13.06.22.
//

import SwiftUI
import SDWebImageSwiftUI
import UIKit

struct TopArtistsView: View {
    var topArtistResponse: TopArtistsResponse
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ForEach(topArtistResponse.items, id: \.id) { artist in
                if let urlString = artist.images?.first?.url,
                   let url = URL(string: urlString) {
                    AnimatedImage(url: url)
                        .frame(width: Double(UIScreen.main.bounds.width) / 5,
                               height: Double(UIScreen.main.bounds.width) / 5)
                }
               
            }
        }
        
    }
}

struct TopArtistsView_Previews: PreviewProvider {
    static var previews: some View {
        TopArtistsView(topArtistResponse: TopArtistsResponse(items: []))
    }
}
