//
//  ConversationsViewModel.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation
import FirebaseAuth
import MessageKit
import SwiftUI
import FirebaseAuth

class AppStateModel: ObservableObject {
    

    
    
    // @Published private(set) var conversations = [Conversation]()
    // @Published var messages = [String: [Message]]()
    
    @Published private(set) var isSignedIn = AuthManager.shared.isSignedIn
    @Published private(set) var isSigningIn = false
    
    @Published private(set) var userIDsInCurrentRoom = [String]()
    @Published var messages = [Message.ChatMessageItem]()

    
    
    /*
    var currentChatUser: Message.ChatUserItem? {
        return Message.ChatUserItem(userName: currentUsername, avatarURL: Auth.auth().currentUser?.photoURL, avatar: nil)
    }
    */
    
    init() {

        if isSignedIn {
            listenForMessages()
        }
    }
    
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }

        return WebView(url: url) { [weak self] success, didStartAuthFlow in
            DispatchQueue.main.async {
                self?.isSignedIn = success
                self?.isSigningIn = didStartAuthFlow
            }
            
        }
    }
    
    func signOut() {
        AuthManager.shared.signOut()
        isSignedIn = false
    }
    

    
}


//MARK: - User related / Match-making

extension AppStateModel {
    /*
     
     func loadUsers() {
         DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
             switch result {
             case .success(let usersCollection):
                 self?.users = usersCollection
             case.failure(let error):
                 print("failed to get users: \(error)")
             }
             
         })
     }
     
     
     */

    
    private func loadMatchingUsers() {
        // match making algorithm
    }


}



//MARK: - Conversations


extension AppStateModel {

    private func listenForMessages() {
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {

            case .success(let room):
                // stop listening for conversations in the previous room
                DatabaseManager.shared.removeMessagesObserver(for: room)
                // empty messages since the room has changed
                self?.messages = []
                
                // update users
                DatabaseManager.shared.getUsers(in: room) { result in
                    switch result {
                    case .success(let newUserIDs):
                        self?.userIDsInCurrentRoom = newUserIDs
                    case .failure(_):
                        print("failed to get users in new room")
                    }
                }
                
                // get messages in new room
                DatabaseManager.shared.listenForMessages(in: room) { result in
                    switch result {
                    case .success(let newMessage):
                        self?.messages += newMessage
                    case .failure(_):
                        print("failed to get message")
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
}
