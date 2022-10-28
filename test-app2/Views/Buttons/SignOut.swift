//
//  SignOut.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI

struct SignOut: View {
    @EnvironmentObject var model: AppStateModel
    @State var isTapping: Bool = false
    var buttonHeight = 25.0
    
    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                }
                DatabaseManager.shared.removePresence()
                model.signOut()
            }
        }, label: {
            HStack(spacing: 0) {
                Text("Log out")
                    .font(.headline)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        })
        .padding(buttonHeight / 2)
        .foregroundColor(.white)
        .background(Color.backdrop)
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .shadow(radius: 5)
    }
}


