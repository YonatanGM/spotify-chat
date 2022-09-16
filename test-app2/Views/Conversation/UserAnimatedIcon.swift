//
//  UserAnimatedIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 15.09.22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserAnimatedIcon: View {
    let url: URL

    @State var scale = 0.001
    var body: some View {
        AnimatedImage(url: url)
        
            .resizable()
            
            .scaledToFill()
            .clipShape(Circle())
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

