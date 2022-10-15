//
//  ArtistCard.swift
//  test-app2
//
//  Created by Yonatan Mamo on 08.10.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ArtistCard: View {
    let artist: Artist
    var body: some View {
        if let urlString = artist.images?.first?.url,
           let url = URL(string: urlString) {
            VStack {
                AnimatedImage(url: url)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(artist.name)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(2)
                    }
                    Spacer()
                }
                Spacer()
            }
            .frame(width: Double(UIScreen.main.bounds.width) / 3)
        }
    }
}
