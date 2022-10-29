//
//  TrackMetadata.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.10.22.
//

import SwiftUI

struct TrackMetadata: View {
    let track: Track
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(track.name)
                    .font(.footnote)
                    // .fontWeight(.bold)
                    .padding(.bottom, 2)
                    .foregroundColor(.white)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                Text(track.artists.map { $0.name }.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
            if let album = track.album {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(album.name)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
            }
        }
    }
}

