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
        VStack(alignment: .leading) {
            Text(track.name)
                .font(.footnote)
                // .fontWeight(.semibold)
                .foregroundColor(.white)
            Text(track.artists.map { $0.name }.joined(separator: ", "))
                .font(.caption)
                .foregroundColor(.white.opacity(0.75))
            if let album = track.album {
                Text(album.name)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.75))
            }
        }
    }
}

