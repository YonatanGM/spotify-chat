//
//  SparkesIconPulsing.swift
//  test-app2
//
//  Created by Yonatan Mamo on 30.06.23.
//

import SwiftUI
import SDWebImageSwiftUI

struct SparklesIconPulsing: View {
    @State var fontWeight: Font.Weight = .regular
    @State var isTapping = false
    @State var isAnimating = false
    
    var size: CGSize
    var disabled: Bool
    var completion: (() -> Void)?
    
    init(size: CGSize, disabled: Bool = false, completion: (() -> Void)? = nil ) {
        self.size = size
        self.disabled = disabled
        self.completion = completion
    }
    
 
    var body: some View {
        Image(systemName: "sparkles")
            .resizable()
            .aspectRatio(contentMode: .fit)
 
            .foregroundColor(.white)
            .fontWeight(fontWeight)
            .animation(.easeInOut, value: fontWeight)
            .scaleEffect(isTapping ? 0.9 : 1)
        
            .frame(width: size.width, height: size.height)
            .overlay {

                AnimatedImage(name: "sparkles3.gif", isAnimating: $isAnimating)
                    .resizable()
                    
                    .scaledToFill()
                
                    .frame(width: size.width * 1.4, height: size.height * 2)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeInOut, value: isAnimating)
                    .offset(x: -5, y: -20)

            }
            .onAppear {
              
                fontWeight = .ultraLight
                isAnimating = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    fontWeight = .bold
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        fontWeight = .regular
    
                    }
                }
                

            }
            .onTapGesture {
                // animation
                if !disabled {
                    withAnimation(.easeIn(duration: 0.1)) {
                        isTapping = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isTapping = false
                        }
                        // do something
                        completion?()
                    }
                }
            }
    }
}
