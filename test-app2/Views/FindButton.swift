//
//  FindButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 12.09.22.
//

import SwiftUI

struct FindButton: View {
    @State var isTapping: Bool = false
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        HStack(spacing:0) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
        }
        .padding([.horizontal], 10)
        .padding([.vertical], 7.5)
        .foregroundColor(.white)
        .background(
            Color(.sRGB,
                  red: Double(24) / 255,
                  green: Double(24) / 255,
                  blue: Double(24) / 255,
                  opacity: 0.5)
        )
        
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .border(.red)
        .onTapGesture {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                    
                }
                model.scrollToBottom = true
            }
            
        }
    }
}

struct FindButton_Previews: PreviewProvider {
    static var previews: some View {
        FindButton()
    }
}
