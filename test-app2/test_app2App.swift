//
//  test_app2App.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import Firebase
import FirebaseFunctions
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
        // UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBar.appearance().standardAppearance
            
            //.scrollEdgeAppearance = navigationBar.standardAppearance
   
        // navBarAppearance.configureWithOpaqueBackground()
        // navBarAppearance.backgroundColor = .gray

        // UINavigationBar.appearance().standardAppearance = navBarAppearance
        // UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
  
        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9092)
        Functions.functions().useEmulator(withHost: "localhost", port: 5002)
           //  .useFunctionsEmulator(origin: "http://localhost:5001")

        // revisit this
        // clear firebase auth cache
        if UserDefaults.standard.value(forKey: "firstTimeOpeningApp") == nil {
            UserDefaults.standard.setValue(true, forKey: "firstTimeOpeningApp")
            try? Auth.auth().signOut()
        }
        
        
        
        
        return true
    }
}
