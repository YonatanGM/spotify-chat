//
//  SparklesIcon.swift
//  test-app2
//
//  Created by Yonatan Mamo on 28.06.23.
//

import SwiftUI

struct SparklesIconRecommendations: View {
    @EnvironmentObject var model: AppStateModel
    // A state variable that stores the foreground color
    @State var foregroundColor = Color.white
    
    // A state variable that stores the hue rotation angle
    @State var hueAngle = Angle.zero
    
    @State var isTapping: Bool = false
    
    let refreshLimit = 10
    
    var body: some View {
        // A system image with a foreground color based on the state variable
        Image(systemName: "sparkles")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 35, height: 35)
            .foregroundColor(foregroundColor)
            // Apply a hue rotation effect based on the state variable
            .hueRotation(hueAngle)
            // Apply an animation when either state variable changes
            // Change both state variables when the user taps on the image
            .padding(.trailing, 5)
            .scaleEffect(isTapping ? 0.9 : 1)
            .brightness(isTapping ? 0.5 : 0)
         
            .onTapGesture {
                // do not allow tapping if isTapping is true
                guard isTapping == false else { return }
                foregroundColor = [Color.green, Color.red, Color.blue].random() ?? Color.green
                withAnimation(.spring(response: 0.5)) {
                    isTapping = true
                    // Change the hue angle to a random value
                    hueAngle = Angle(degrees: Double.random(in: 0...360))
                }
                if let user = model.currentUser {
                    DatabaseManager.shared.refreshRecommendations(for: user) { didRefresh, count in
                        print("refresh \(didRefresh) count \(count)")
                        DispatchQueue.main.async {
                            // UI animation
                            withAnimation {
                                isTapping = false
                                foregroundColor = Color.white
                                hueAngle = .zero
                            }

                            // pause the player if new tracks got loaded
                            if didRefresh {
                                model.removePlayer()
                            }
                            
                            if count == refreshLimit - 1 {
                                model.recommendationLimitMessage = "Heads up! You have only one refresh left for this week."
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    model.recommendationLimitMessage = nil
                                }
                            } else if !didRefresh && count >= refreshLimit {
                          
                                    model.recommendationLimitMessage = "You have used up all your refreshes for this week. "
                                
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        model.recommendationLimitMessage = nil
                                }
                            }
                            
                        }
                        
                    }
                }

            }

        
    }
}
