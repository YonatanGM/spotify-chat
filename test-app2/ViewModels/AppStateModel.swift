//
//  ConversationsViewModel.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation
import FirebaseAuth
import SwiftUI
import FirebaseAuth
import Combine
import SpriteKit
import SwiftyChat
import AVKit


class AppStateModel: ObservableObject {
    
    enum SignInStatus {
        case signedIn
        case signingIn
        case notDetermined
        case signedOut
    }
    
    @Published private(set) var signInStatus: SignInStatus = .notDetermined
    
    // @Published private(set) var users = [Message.ChatUserItem]()
    @Published var usersInCurrentRoom = [Message.ChatUserItem]()
    @Published var messages = [Message.ChatMessageItem]()
    @Published var currentRoom: String?
    

    @Published  var selectedTrackID: String?
    @Published  var playingTrackID: String?
    // assume spotify is not installed 
    @Published var isSpotifyInstalled = false
    
    @Published var scrollToBottom = false
    
    private var cancellables = Set<AnyCancellable>()
    
    
    
    // Group
    @Published var groups = [Group]()
    @Published var pendingGroups = [Group]()
    
    init() {
        // check if spotify is installed
        // ... if I want to open appstore in case spotify is not installed 
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            isSpotifyInstalled = true
        }
        
        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                // self?.listenForMessages()
                self?.setup()
            }
        })
        .store(in: &cancellables)
        
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            AuthManager.shared.currentUser = user
            if AuthManager.shared.isSignedIn {
                AuthManager.shared.refreshIfNeeded()
                self?.signInStatus = .signedIn
            } else {
                DatabaseManager.shared.removeRoomChangeObserver()
                self?.signInStatus = .signedOut
            }
        }
        
        

    }
    
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }
        return WebView(url: url) { [weak self] success, didStartAuthFlow in
            DispatchQueue.main.async {
                self?.signInStatus = didStartAuthFlow ? .signingIn : (success ? .signedIn : .signedOut)
            }
        }
    }
    
    
    func signOut() {
        AuthManager.shared.signOut()
        signInStatus = .signedOut
    }

}


//MARK: - Conversations

extension AppStateModel {
    
    

    private func listenForMessages() {
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {

            case .success(let room):
                // stop listening for conversations in the previous room
                if let currentRoom = self?.currentRoom {
                    DatabaseManager.shared.removeMessagesObserver(currentRoom)
                }
                
                self?.currentRoom = room
                
                // empty messages since the room has changed
                self?.messages = []
                
                // remove old users
                self?.usersInCurrentRoom = []
                
                // update the users
                DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        self?.usersInCurrentRoom = users
                    case .failure(_):
                        print("failed to get users in new room")
                    }
                    
                })
                
                // get messages in the new room
                DatabaseManager.shared.listenForMessages(in: room) { result in
                    switch result {
                    case .success(let newMessage):
                        self?.messages.append(newMessage)
                    case .failure(_):
                        print("failed to get message")
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    
    private func setup() {
        
        DatabaseManager.shared.observeUserAdditionToGroup() { [weak self] groupID in
            DatabaseManager.shared.getGroup(with: groupID) { result in
                switch result {
                case .success(let group):
                    self?.groups.append(group)
                case .failure(_):
                    print("failed to get group with id \(groupID)")
                }
            }
            
        }
        
        DatabaseManager.shared.observeUserRemovalFromGroup() { [weak self] groupID in
            guard let strongSelf = self else { return }
            strongSelf.groups = strongSelf.groups.filter { $0.id != groupID }

        }
            
        
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {

            case .success(let room):
                // stop listening for conversations in the previous room
                if let currentRoom = self?.currentRoom {
                    DatabaseManager.shared.removeMessagesObserver(currentRoom)
                }
                
                self?.currentRoom = room
                
                // empty messages since the room has changed
                self?.messages = []
                
                // remove old users
                self?.usersInCurrentRoom = []
                
                // update the users
                DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        print(users.map { $0.userName })
          
                        self?.usersInCurrentRoom = users
                        print( self?.usersInCurrentRoom)
                    case .failure(_):
                        print("failed to get users in new room")
                    }
                    
                })
                
                // get messages in the new room
                DatabaseManager.shared.listenForMessages(in: room) { result in
                    switch result {
                    case .success(let newMessage):
                        self?.messages.append(newMessage)
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

