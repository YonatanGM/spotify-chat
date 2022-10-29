//
//  ArtistBackgroundSlideshow.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.10.22.
//

import SwiftUI
import SDWebImageSwiftUI
struct ArtistBackgroundSlideshow: View {
    let urls: [URL]
    @State var currentPicIndex = 1

    // every 10 secs
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack {
            ForEach(Array(urls.enumerated()), id: \.offset) { index, url in
                AnimatedImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: Double(UIScreen.main.bounds.height) / 7)
                    .clipped()
                    .opacity(currentPicIndex == index ? 1 : 0)
                
                
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeIn(duration: 0.5)) {
                currentPicIndex = (currentPicIndex + 1) % urls.count
            }
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
    }
}

