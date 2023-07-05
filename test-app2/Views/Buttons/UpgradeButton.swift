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
    @State var hueAngle = Angle.zero
    @State var shouldAnimateHue = false
    var buttonHeight = 25.0
    
    var body: some View {
        Button(action: {
            guard model.didRequestProduct == false else { return }
            withAnimation {
                isTapping = true
            }
            
            
            Task {
                do {
                    try await model.purchase()
                    withAnimation(.easeIn) {
                        isTapping = false
                    }
                } catch {
                    print(error.localizedDescription)
                    withAnimation {
                        isTapping = false
                    }
                }
            }
            
        }, label: {
            HStack(spacing: 0) {
                if isTapping {
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .foregroundColor(.blue)
                        .hueRotation(hueAngle)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                                hueAngle = Angle(degrees: Double.random(in: 0...360))
                                
                            }
                        }
                    
                } else {
                    Image(systemName: "sparkles")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                }
                Text("Upgrade")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        })
        .padding(.horizontal, 5)
        .foregroundColor(.white)
        .background(Color.black.opacity(0.1))
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .allowsHitTesting(!isTapping)
        
    }
    
    
}

