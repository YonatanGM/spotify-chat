//
//  InviteButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct InviteButton: View {
    var body: some View {
        HStack(spacing:0) {
            Image(systemName: "plus")
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
    }
}

struct InviteButton_Previews: PreviewProvider {
    static var previews: some View {
        InviteButton()
    }
}
