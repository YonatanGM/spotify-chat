//
//  SparklesIconPremium.swift
//  test-app2
//
//  Created by Yonatan Mamo on 01.07.23.
//

import SwiftUI

struct SparklesIconPremium: View {
    @State var foregroundColor = Color.white
    
    // A state variable that stores the hue rotation angle
    @State var hueAngle = Angle.zero
 
    var body: some View {
        Image(systemName: "sparkles")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.white)
            .onAppear {
                foregroundColor = Color.green
                withAnimation(.spring(response: 0.5)) {
                    // Change the hue angle to a random value
                    hueAngle = Angle(degrees: Double.random(in: 0...360))
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation {
                        foregroundColor = Color.white
                        hueAngle = .zero
                    }
                }
            }
    }
}

