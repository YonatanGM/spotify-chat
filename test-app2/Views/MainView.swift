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
                
        NavigationView {
            if model.signInStatus == .signedOut || model.signInStatus == .signingIn {
                LoginView()
                    .navigationTitle("Login")
            } else if model.signInStatus == .signedIn {
                Home()
                    .navigationTitle("App name")
            }
        
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
