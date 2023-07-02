//
//  SparkesIconPulsing.swift
//  test-app2
//
//  Created by Yonatan Mamo on 30.06.23.
//

import SwiftUI

struct SparklesIconPulsing: View {
    @State var isBold = false
    @State var isTapping = false
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
            //.fontWeight(isBold ? .black : .regular)
            .animation(.spring(response: 0.5, dampingFraction: 0.5), value: isBold)
            .scaleEffect(isTapping ? 0.9 : 1)
        

            .frame(width: size.width, height: size.height)
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatCount(2)) {
                    isBold = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(Animation.linear(duration: 2).delay(1).repeatCount(2)) {
                        isBold = false
                    }
                }
            }
            .onDisappear {
                isBold = false
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
