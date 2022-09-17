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
            Color.black.opacity(0.25)
                .shadow(radius: 5)
            Text(genre)
                .font(.footnote)
                .padding([.horizontal], 7.5)
                .padding([.vertical], 2.5)
        }
   
        .clipShape(Capsule())

        .scaleEffect(scale)
        .shadow(radius: 10)

        .foregroundColor(.white)
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
