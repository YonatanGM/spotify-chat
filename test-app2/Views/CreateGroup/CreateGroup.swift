//
//  CreateGroup.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.09.22.
//

import SwiftUI

struct CreateGroup: View {
    @State var isTapping: Bool = false
    @EnvironmentObject var model: AppStateModel
    @Binding var present: Bool
    @State var name = ""
    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(colors: [
                Color(.sRGB,
                      red: Double(20) / 255,
                      green: Double(20) / 255,
                      blue: Double(20) / 255,
                      opacity: 0.75),
                Color(.sRGB,
                      red: Double(10) / 255,
                      green: Double(10) / 255,
                      blue: Double(10) / 255,
                      opacity: 1)
                
            ], startPoint: .topLeading, endPoint: .bottom)
            ScrollView {
                VStack {
                    
                    HStack {
                        Spacer()
                        HStack {
                            Text("Done")
                                .font(.headline)
                        }
                        .padding([.horizontal], 10)
                        .padding([.vertical], 7.5)
                        
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
                                present = false
                            }
                        }
                    }
                    .padding([.top, .trailing], 10)
                    
                    
                    TextField("Name of group", text: $name) {
                    }
                    .accentColor(.black)
                    .keyboardType(.webSearch)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
    //                .clipShape(Capsule())
                    .frame(height: 40)
                    .foregroundColor(.black)
                        
                   
                    .padding([.horizontal], 10)
                    UserCardViewGroupCreation()
                        
                    
                    Spacer()
                }
                .foregroundColor(.white)
            }
        }
    }
}

