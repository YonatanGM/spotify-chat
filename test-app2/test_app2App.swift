//
//  test_app2App.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import Firebase
import JGProgressHUD_SwiftUI


@main
struct test_app2App: App {
    @StateObject var settings = AppStateModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(settings)
     
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9098)
    
        if UserDefaults.standard.value(forKey: "appFirstTimeOpend") == nil {
            UserDefaults.standard.setValue(true, forKey: "appFirstTimeOpend")
            try? Auth.auth().signOut()
      
        } else {
            
            if AuthManager.shared.isSignedIn {
                AuthManager.shared.refreshIfNeeded()
            }

            Auth.auth().addStateDidChangeListener { auth, user in
                if user == nil {
                    // detach all observers from all database references that have observes
                }
                
                AuthManager.currentUser = user
                
            }

        }

        return true
    }
}
