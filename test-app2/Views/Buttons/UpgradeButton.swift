//
//  SubscribeButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 26.06.23.
//

import SwiftUI
import StoreKit
import Foundation
import StoreKit



struct UpgradeButton: View {
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
            }
            if !model.didUnlockPremium {
                Task {
                    do {
                        try await model.purchase()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }, label: {
            HStack(spacing: 0) {
                Image(systemName: "sparkles")
                if !model.didUnlockPremium {
                    Text("Upgrade")
                        .font(.caption2)
                        .fontWeight(.semibold)
                } else {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        })
//        .padding(buttonHeight / 2)
        .padding(.horizontal, 5)
        .foregroundColor(.white)
        .background(Color.black.opacity(0.1))
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)

    }
    

}

