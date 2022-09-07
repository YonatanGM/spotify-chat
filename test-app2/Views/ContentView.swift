//
//  ContentView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var model: AppStateModel
    
    @State var profile: UserProfileResponse?

    
    var body: some View {
                
        NavigationView {
            ZStack {
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
  
                ], startPoint: .top, endPoint: .center)

              
                if model.signInStatus == .signedOut || model.signInStatus == .signingIn {
                    LoginView()
                } else if model.signInStatus == .signedIn {
                    VStack {
                        TopArtistsView()
                        
                        TopTracksView()
                        Spacer()
                    }
                    
                    
                        
                    /*
                    VStack {
                        Divider()
                        UsersMap()
                        Divider()
                        Spacer()
                        Divider()
                        
                        Chat()
                            .frame(height: 200)
                        
                    }
                     */
                    // .navigationBarTitle("testApp", displayMode: .inline)
                   
                    
                    
                    
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
