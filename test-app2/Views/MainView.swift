//
//  ContentView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    
    @EnvironmentObject var model: AppStateModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            
                if model.signInStatus == .signedOut || model.signInStatus == .signingIn || model.finishedLoadingOfSuggestedUsers == false {
                    Login()
                } else if model.signInStatus == .signedIn {
                    NavigationStack {
                        Home()
                            .navigationTitle("⁢⁢\u{17B5} \u{17B4} \u{115F}")
                    }
                    .navigationViewStyle(.stack)
                    .tint(.white)
                } else {
                    LinearGradient(colors: [
                        Color(.sRGB,
                              red: Double(20) / 255,
                              green: Double(20) / 255,
                              blue: Double(20) / 255,
                              opacity: 0.6),
                        Color(.sRGB,
                              red: Double(10) / 255,
                              green: Double(10) / 255,
                              blue: Double(10) / 255,
                              opacity: 1)
                        
                    ], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                }
            
           
        } else {
            NavigationView {
                if model.signInStatus == .signedOut || model.signInStatus == .signingIn || model.finishedLoadingOfSuggestedUsers == false {
                    Login()
                } else if model.signInStatus == .signedIn {
                    Home()
                        .navigationTitle("⁢⁢\u{17B5} \u{17B4} \u{115F}")
                } else {
                    LinearGradient(colors: [
                        Color(.sRGB,
                              red: Double(20) / 255,
                              green: Double(20) / 255,
                              blue: Double(20) / 255,
                              opacity: 0.6),
                        Color(.sRGB,
                              red: Double(10) / 255,
                              green: Double(10) / 255,
                              blue: Double(10) / 255,
                              opacity: 1)
                        
                    ], startPoint: .topLeading, endPoint: .center)
                    .edgesIgnoringSafeArea(.all)
                }
                
            }
            .navigationViewStyle(.stack)
            
            
        }
    }
}

