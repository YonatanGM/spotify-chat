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
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, .font : UIFont(name: "Glyphter", size: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)!]
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, .font : UIFont(name: "Glyphter2", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)!]

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Glyphter2", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)!], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Glyphter2", size: UIFont.preferredFont(forTextStyle: .headline).pointSize)!], for: .highlighted)

        UINavigationBar.appearance().barTintColor = UIColor(.chatSpotifyColor)
        UINavigationBar.appearance().tintColor  = .white

        // firebase
        FirebaseApp.configure()
        Auth.auth().useEmulator(withHost: "localhost", port: 9092)
        Functions.functions().useEmulator(withHost: "localhost", port: 5002)

        // revisit this
        // clear firebase auth cache
        if UserDefaults.standard.value(forKey: "firstTimeOpeningApp") == nil {
            UserDefaults.standard.setValue(true, forKey: "firstTimeOpeningApp")
            try? Auth.auth().signOut()
        }
        
        return true
    }
}
