//
//  followOnSpotify.swift
//  test-app2
//
//  Created by Yonatan Mamo on 03.10.22.
//

import SwiftUI

struct FollowOnSpotify: View {
    @State var isTapping: Bool = false
    var logoHeight = 25.0
    let isFollowing: Bool
    var completion: () -> Void
    
    var body: some View {
        Button(action: {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                // do something
                completion()
            }
        }, label: {
            if !isFollowing {
                HStack(spacing: 0) {

                    Text("Follow on")
                        .font(.headline)
                        // .fontWeight(.bold)
                        // .font(.system(size: 15, weight: .bold, design: .default))
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    Image("Spotify_Logo_RGB_White")
                        .resizable()
                        .scaledToFit()
                        .frame(height: logoHeight)
                        // .border(.red)
                        .padding(.leading, logoHeight / 2)
       
                }
            } else {
                HStack(spacing: 0) {
 
                    Text("Following")
                        .font(.headline)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                        // .fontWeight(.bold)
                        // .font(.system(size: 12, weight: .bold, design: .default))
                   
                    Image("Spotify_Icon_RGB_White-1")
                        .resizable()
                        .scaledToFit()
                        .frame(height: logoHeight)
                        .padding(.leading, logoHeight / 2)
   
                }
            }
           
        })
         .padding(logoHeight / 2)
        .foregroundColor(.white)
        .background(
            Color.backdrop
        )
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .shadow(radius: 5)
    }
}
