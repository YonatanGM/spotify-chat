//
//  test_app2App.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import Firebase
import FirebaseFunctions
import FirebaseDatabase
import SDWebImageSwiftUI



@main
struct test_app2App: App {
    @StateObject var settings = AppStateModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate
    var body: some Scene {
        
        WindowGroup {
            MainView()
                .environmentObject(settings)
                .preferredColorScheme(.light)
     
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // navigation bar apearance
        UINavigationBar.appearance().barTintColor = UIColor(.chatSpotifyColor)
        UINavigationBar.appearance().tintColor  = .white

        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, .font : UIFont(name: "Modulus-Bold", size: 40)!]

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, .font : UIFont(name: "Modulus-Bold2", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)!]

        // back button
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Modulus-Bold2", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)!], for: .normal)
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Modulus-Bold2", size: UIFont.preferredFont(forTextStyle: .title2).pointSize)!], for: .highlighted)

        // remove scroll indicator from list
        UITableView.appearance().showsVerticalScrollIndicator = false

        // firebase
        FirebaseApp.configure()

        // FirebaseConfiguration.shared.setLoggerLevel(.min)
        Auth.auth().useEmulator(withHost: "192.168.178.87", port: 9092)
        Functions.functions().useEmulator(withHost: "192.168.178.87", port: 5002)
   
    

        // revisit this
        // clear firebase auth cache
        if UserDefaults.standard.value(forKey: "firstTimeOpeningApp") == nil {
            UserDefaults.standard.setValue(true, forKey: "firstTimeOpeningApp")
            try? Auth.auth().signOut()
        }
        
        // Add multiple caches

        // let cache = SDImageCache(namespace: "tiny")
        // cache.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB memory
        // cache.config.maxDiskSize = 50 * 1024 * 1024 // 50MB disk
        // cache.config.shouldCacheImagesInMemory = false
//        SDImageCache.shared().config.shouldDecompressImages = false
//
//        SDWebImageDownloader.shared().shouldDecompressImages = false
                
//        SDImageCache.shared().config.diskCacheReadingOptions = NSData.ReadingOptions.mappedIfSafe
         SDImageCache.shared.config.maxMemoryCost = 400 * 1024 * 1024
         // SDWebImageManager.defaultImageCache = SDImageCachesManager.shared
        return true
    }
}
