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
    init() {
        
    }
    @StateObject var settings = AppStateModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(.dark)
     
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9098)
        

    
        if UserDefaults.standard.value(forKey: "appFirstTimeOpened") == nil {
            UserDefaults.standard.setValue(true, forKey: "appFirstTimeOpened")
            try? Auth.auth().signOut()
        }
        
        return true
    }
}
