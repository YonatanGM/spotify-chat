//
//  InviteButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 09.09.22.
//

import SwiftUI

struct InviteButton: View {
    @State var isTapping: Bool = false
    @State private var isSharePresented: Bool = false
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
            Color.backdrop
        )
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                isSharePresented = true
            }
            
        }
        .sheet(isPresented: $isSharePresented, onDismiss: {
            // print("Dismiss")
        }, content: {
            ActivityViewController(activityItems: ["mklsdmflksdf sdf sdfsdf"])
        })
    }
}

struct InviteButton_Previews: PreviewProvider {
    static var previews: some View {
        InviteButton()
    }
}
