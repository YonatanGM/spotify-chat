//
//  GenresAnimatedIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.09.22.
//

import SwiftUI

struct GenresAnimatedIcon: View {
    let genre: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
                .shadow(radius: 5)
            Text(genre)
                .font(.caption)
                .padding([.horizontal], 7.5)
                .padding([.vertical], 2.5)
        }
   
        .clipShape(Capsule())
        .shadow(radius: 10)
        .foregroundColor(.white)

    }
}
