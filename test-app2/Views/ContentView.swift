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
            if model.signInStatus == .signedOut || model.signInStatus == .signingIn {
                LoginView()
            } else if model.signInStatus == .signedIn {
                
                VStack {
                    Divider()
                    UsersMap()
                    Divider()
                    Spacer()
                    Divider()
                    
                    Chat()
                        .frame(height: 200)
                    
                    
 

                }
                .navigationBarTitle("MUSIQ", displayMode: .inline)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
