//
//  ContentView.swift
//  test-app2
//
//  Created by Yonatan Mamo on 14.04.22.
//

import SwiftUI
import MessageKit
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var model: AppStateModel
    
    @State var profile: UserProfileResponse?

    
    var body: some View {
                
        if !model.isSignedIn {
            LoginView()
        } else {
            TabView {
                UsersMap()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                

            }
            .onAppear {
                APICaller.shared.getAvailableGenres { _ in
                    
                }
                APICaller.shared.getTopArtists { _ in}
                APICaller.shared.getTopTracks { _ in}
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
