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
            MainView()
                .environmentObject(settings)
     
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // navigation bar apearance
        // UINavigationBar.appearance().backgroundColor = .orange

        //Use this if NavigationBarTitle is with Large Font
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().titleTextAttributes =  [NSAttributedString.Key.foregroundColor: UIColor.white]
        // firebase
        UINavigationBar.appearance().barTintColor = UIColor(.chatSpotifyColor)
        UINavigationBar.appearance().tintColor  = .white
   
        // navBarAppearance.configureWithOpaqueBackground()
        // navBarAppearance.backgroundColor = .gray

        // UINavigationBar.appearance().standardAppearance = navBarAppearance
        // UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
  
        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9091)
        

        // revisit this
        // clear firebase auth cache
        if UserDefaults.standard.value(forKey: "appFirstTimeOpened") == nil {
            UserDefaults.standard.setValue(true, forKey: "appFirstTimeOpened")
            try? Auth.auth().signOut()
        }
        
        
        
        
        return true
    }
}
