//
//  ConversationGroupRow.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ConversationGroupRow: View {
    let group: Group
    var body: some View {
        ZStack {
            ConversationRowUserPicBubbles(group: group)
            .border(.green)
            VStack(alignment: .leading, spacing: 0) {
                Text(group.name)
                    .font(.title)
//                ScrollView(.horizontal, showsIndicators: false) {
//                    LazyHStack(spacing: 1) {
//                        ForEach(group.genres_display, id: \.self) { genre in
//                            GenresAnimatedIcon(genre: genre)
//                        }
//                    }
//                }
//                .frame(height: 25)
//                .cornerRadius(10)
//                .border(.blue)
            }
        }
        .foregroundColor(.white)
        .background(Color.backdrop)
        .cornerRadius(20)
    }
}

