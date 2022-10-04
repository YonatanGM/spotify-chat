//
//  DeleteAccount.swift
//  test-app2
//
//  Created by Yonatan Mamo on 04.10.22.
//

import SwiftUI

struct DeleteAccount: View {
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
                // do something
            }
        }, label: {
            HStack(spacing: 0) {
                Text("Delete profile")
                    // .font(.headline)
                    .font(.system(size: 15, weight: .bold, design: .default))
                    // .fontWeight(.bold)
                   // .foregroundColor(.red.opacity(1))
                
            }
        })
        .padding(buttonHeight / 2)
        .foregroundColor(.white)
        .background(Color.red.opacity(0.05))
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .shadow(radius: 5)
    }
}

