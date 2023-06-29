//
//  SparklesIconBio.swift
//  test-app2
//
//  Created by Yonatan Mamo on 29.06.23.
//

import SwiftUI


struct SparklesIconBio: View {
    @EnvironmentObject var model: AppStateModel
    // A state variable that stores the foreground color
    @State var foregroundColor = Color.white
    
    // A state variable that stores the hue rotation angle
    @State var hueAngle = Angle.zero
    
    @State var isTapping: Bool = false
    
    var body: some View {
        // A system image with a foreground color based on the state variable
        Image(systemName: "sparkles")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25)
            .foregroundColor(foregroundColor)
        // Apply a hue rotation effect based on the state variable
            .hueRotation(hueAngle)
        // Apply an animation when either state variable changes
        // Change both state variables when the user taps on the image
            .padding(.trailing, 5)
            .scaleEffect(isTapping ? 0.9 : 1)
            .brightness(isTapping ? 0.1 : 0)
        
            .onTapGesture {
                // do not allow tapping if isTapping is true
                guard isTapping == false else { return }
                foregroundColor = Color.green
                withAnimation(.spring(response: 0.5)) {
                    isTapping = true
                    // Change the hue angle to a random value
                    hueAngle = Angle(degrees: Double.random(in: 0...360))
                }
                Task {
                    await model.updateBio()
                    withAnimation {
                        isTapping = false
                        foregroundColor = Color.white
                        hueAngle = .zero
                    }
                }
                
            }
    }
}
