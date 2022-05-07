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
  
    @State private var isLoggedIn = AuthManager.shared.isSignedIn
    
    @State var profile: UserProfile?
    @State var messages: [MessageType] = [Message(sender: Sender(senderId: "1", displayName: "me", photoURL: ""),
                            messageId: "2",
                            sentDate: Date(),
                            kind: .text("hello there"))]
    
    var body: some View {
                
        if !isLoggedIn {
            LoginView($isLoggedIn)
        } else {
            
            
        }
        

                            
                        

//                } else {
//
                    Text("Profile")
                        .onTapGesture {
                            getUserProfile()

                        }

                    Text("Top artists")
                        .onTapGesture {
                            getTopArtists()
                        }

                    Text("Top tracks")
                        .onTapGesture {
                            getTopTracks()
                        }

                    Text("Test database")
                        .onTapGesture {
                            DatabaseManager.shared.userExists(with: Auth.auth().currentUser!.uid) {

                                print("eiiii ", $0)
                            }

                        }
//                }
        
                if let profile = profile {
                    UserProfileView(profile: profile)
                }

    }
    
    func handleSignIn(success: Bool) {
        guard success else {
            return
        }
    }
    
    func getUserProfile() {
        APICaller.shared.getUserProfile {
            result in
            
            switch result {
            case .success(let profile):
                self.profile = profile
                break
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getTopArtists() {
        APICaller.shared.getTopArtists {
            result in
            
            switch result {
            case .success(let profile):
                // self.profile = profile
                break
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getTopTracks() {
        APICaller.shared.getTopTracks {
            result in
            
            switch result {
            case .success(let profile):
                // self.profile = profile
                break
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
     
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
