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
                    .frame(height: Double(UIScreen.main.bounds.width) / 3)
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text(artist.name)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineLimit(1)

                    }
                    Spacer()
                }
                Spacer()

            }
            .cornerRadius(5)
        }
    }
}
