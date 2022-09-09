//
//  ChatButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI
import UIKit

struct ChatButton: View {
    let numOfUnseenMessages = 0
    var body: some View {
        HStack(spacing:0) {
            Image(systemName: "paperplane.fill")
                .resizable()
                .scaledToFit()
            if numOfUnseenMessages > 0 {
                Text("\(numOfUnseenMessages)")
                    .scaleEffect(0.8, anchor: .topTrailing)
                
                
            }
            
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
               
    }
       


}


struct ChatButton_Previews: PreviewProvider {
    static var previews: some View {
        ChatButton()
    }
}
