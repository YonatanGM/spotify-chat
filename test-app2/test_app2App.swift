//
//  test_app2App.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import Firebase


@main
struct test_app2App: App {
    init() {
        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9098)
        print("init", Auth.auth().currentUser?.uid)
        if AuthManager.shared.isSignedIn {
            AuthManager.shared.refreshIfNeeded()
            
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
