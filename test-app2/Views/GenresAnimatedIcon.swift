//
//  GenresAnimatedIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.09.22.
//

import SwiftUI

struct GenresAnimatedIcon: View {
    let genre: String

    @State var scale = 0.001
    var body: some View {
        ZStack {
            Color.backdrop
            Text(genre)
                .font(.footnote)
                .fontWeight(.thin)
        }
        .clipShape(Capsule())
        .shadow(radius: 5)
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                scale = 1.0

            }
           
        }
        .onDisappear {
            withAnimation(.easeIn(duration: 0.2)) {
                scale = 0.001
            }
        }

    }
}
