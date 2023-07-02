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
    var completion: (() -> Void)?
    
    var body: some View {
        Button(action: {
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            
            DatabaseManager.shared.deleteProfile {
                withAnimation {
                    isTapping = false
                }
                completion?()
                model.signOut()
            }
            
        }, label: {
            HStack(spacing: 0) {
                Text("Delete profile")
                     .font(.headline)
                     //.minimumScaleFactor(0.5)
                     .fixedSize()
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

