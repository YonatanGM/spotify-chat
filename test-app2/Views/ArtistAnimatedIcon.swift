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
    let shouldAnimate: Bool
    @State var scale = 0.001
    
    var body: some View {
        AnimatedImage(url: url)
        
            .resizable()
            
            .scaledToFit()
            .clipShape(Circle())
            .scaleEffect(shouldAnimate ? scale : 1.0)
            .onAppear {
                withAnimation(.easeIn(duration: 0.2)) {
                    scale = 1.0
                    print("md")
                }
               
            }
            .onDisappear {
                withAnimation(.easeIn(duration: 0.2)) {
                    scale = 0.001
                }
            }
    }
}

/*
struct ArtistAnimatedIcon_Previews: PreviewProvider {
    static var previews: some View {
        ArtistAnimatedIcon()
    }
}
*/
