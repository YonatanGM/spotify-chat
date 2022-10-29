//
//  ArtistAnimatedIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ArtistAnimatedIcon: View {
    let url: URL

    @State var scale = 0.001

    var body: some View {
        AnimatedImage(url: url)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .shadow(radius: 5)
            .scaleEffect(scale)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            if geometry.frame(in: .named("artistIcons")).minX < 0 || geometry.frame(in: .named("artistIcons")).minX > 115 {
                                withAnimation(.easeIn(duration: 0.2)) {
                                    scale = 1.0

                                }
                            } else {
                                scale = 1.0
                            }
                        }
                        .onDisappear {
                            if geometry.frame(in: .named("artistIcons")).minX < 0 || geometry.frame(in: .named("artistIcons")).minX > 115 {
                                withAnimation(.easeIn(duration: 0.2)) {
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

