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
    let parentFrame: CGSize
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
        .contentShape(Capsule())
        .shadow(radius: 10)
        .foregroundColor(.white)
        .scaleEffect(scale)
        .overlay(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        if geometry.frame(in: .named("userDetailGenres")).minX < 0 || geometry.frame(in: .named("userDetailGenres")).maxX > parentFrame.width {
                            withAnimation(.spring(response: 0.5)) {
                                scale = 1.0
                            }
                        } else {
                            scale = 1.0
                        }
                    }
                    .onDisappear {
                        if geometry.frame(in: .named("userDetailGenres")).minX < 0 || geometry.frame(in: .named("userDetailGenres")).maxX > parentFrame.width {
                            withAnimation(.spring(response: 0.5)) {
                                scale = 0.001
                            }
                        } else {
                            scale = 0.001
                        }
                    }
            }
        )

    }
}
