//
//  NewGroupButton.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct NewGroupButton: View {
    @State var isTapping: Bool = false
    @State var presentSheet: Bool = false
    var body: some View {
        HStack {
            Image(systemName: "plus")
                .resizable()
                .scaledToFit()
            Text("New group")
                .font(.headline)
        }
        .padding([.horizontal], 10)
        .padding([.vertical], 7.5)
        .foregroundColor(.white)
        .background(
            Color.backdrop
        )
        
        .clipShape(Capsule())
        .scaleEffect(isTapping ? 0.9 : 1)
        .brightness(isTapping ? 0.1 : 0)
        .onTapGesture {
            // animation
            withAnimation(.easeIn(duration: 0.1)) {
                isTapping = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    isTapping = false
                    
                }
                presentSheet = true

            }
            
        }
        
        .sheet(isPresented: $presentSheet,
               onDismiss: {

        }) {
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [
                    Color(.sRGB,
                          red: Double(18) / 255,
                          green: Double(18) / 255,
                          blue: Double(18) / 255,
                          opacity: 0.75),
                    Color(.sRGB,
                          red: Double(18) / 255,
                          green: Double(18) / 255,
                          blue: Double(18) / 255,
                          opacity: 1)
  
                ], startPoint: .top, endPoint: .bottom)
                VStack {
                    
                    HStack {
                        Spacer()
                        HStack {
                            Text("Done")
                                .font(.headline)
                        }
                        .padding([.horizontal], 10)
                        .padding([.vertical], 7.5)
                        .foregroundColor(.white)
                        .background(
                            Color.backdrop
                        )
                        
                    }
                    Spacer()
                }
                
            }

      

        }

    }
}

struct NewGroupButton_Previews: PreviewProvider {
    static var previews: some View {
        NewGroupButton()
    }
}
