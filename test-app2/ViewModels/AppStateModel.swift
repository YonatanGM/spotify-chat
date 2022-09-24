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
    @Published var suggestedUsers = [Message.ChatUserItem]()
    @Published var messages = [Message.ChatMessageItem]()
    @Published var currentRoom: String?
    
    
    @Published  var selectedTrackID: String?
    @Published  var playingTrackID: String?
    // assume spotify is not installed
    @Published var isSpotifyInstalled = false
    
    @Published var scrollToBottom = false
    @Published var searchResults = [Message.ChatUserItem]()
    
    
    private var cancellables = Set<AnyCancellable>()

    // Group
    @Published var groups = [String: Group]()
    // @Published var groups = [Group]()
    @Published var pendingGroups = [Group]()
    
    init() {
        // check if spotify is installed
        // ... if I want to open appstore in case spotify is not installed
        if let url = URL(string: "spotify://"), UIApplication.shared.canOpenURL(url) {
            isSpotifyInstalled = true
        }

        self.$signInStatus.sink(receiveValue: { [weak self] signInStatus in
            if signInStatus == .signedIn {
                self?.setup()
            }
        })
        .store(in: &cancellables)
        

        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            AuthManager.shared.currentUser = user
            
            if user != nil {
                AuthManager.shared.refreshIfNeeded()
                self?.signInStatus = .signedIn
            } else {
                // remove observers here
                self?.signInStatus = .signedOut
            }
        }
    }
    
    func signIn(completion: @escaping (Bool) -> Void) -> WebView? {
        guard let url = AuthManager.shared.signInUrl else {
            return nil
        }
        return WebView(url: url) { [weak self] didStartAuthFlow in
            DispatchQueue.main.async {
                if didStartAuthFlow {
                    self?.signInStatus = .signingIn
                }
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
    
    public func setup() {
        DatabaseManager.shared.managePresence()
        
        DatabaseManager.shared.observeNewGroup() { [weak self] result in
            switch result {
            case .success(let (groupID, userHasJoined)):
                
                DatabaseManager.shared.getGroup(with: groupID) { [weak self] result in
                    switch result {
                    case .success(var group):
                        group.pending = !userHasJoined
                        // self?.groups.append(group)
                        self?.groups[groupID] = group
                        // self?.groups.insert(group, at: 0)
                        // observe change in group child nodes
                        DatabaseManager.shared.observeChangesInGroup(with: groupID) { result in
                            switch result {
                            
                            case .success(let (key, snapshotValue)):
                                // update group name
                                // print(key, snapshotValue)
                                if key == "name" {
                                    if let name = snapshotValue as? String {
                                        self?.groups[groupID]?.name = name
                                    }
                                } else if key == "users" {
                                    // update group users (in case a user joins or leaves the group)
                                    var users = [UserInfo]()
                                    if let usersInfoDict = snapshotValue as? [String: [String: String]] {
                                        for (id, userInfo) in usersInfoDict {
                                            if let name = userInfo["name"] {
                                                users.append(UserInfo(id: id, name: name, photoURL: userInfo["photoURL"], genreDisplay: userInfo["top_genre_display"]))
                                            }
                                        }
                                        self?.groups[groupID]?.users = users
                                    }
                                }
                                
                            case .failure(_):
                                print("failed to get changes at child locations of group \(groupID)")
                            }
                        }
                        if userHasJoined {
                            DatabaseManager.shared.listenForMessages(in: group.id) { result in
                                switch result {
                                case .success(let message):
                                    // find the index
                                    // shouldn't take too long to find the index hopefully
                                    /*
                                    if let index = self?.groups.firstIndex(where: { $0.id == group.id }) {
                                        self?.groups[index].messages.append(message)
                                    }
                                    */
                                    self?.groups[groupID]?.messages.append(message)
                                    
                                case .failure(_):
                                    print("failed to get messages in group \(group.id)")
                                }
                            }
                        }
                        
                    case .failure(_):
                        print("failed to get group with id \(groupID)")
                    }
                }
            case .failure(_):
                print("failed to get new group")
            }
            
        }
        
        DatabaseManager.shared.observeGroupRemoval() { [weak self] groupID in
            // self?.groups.removeAll { $0.id == groupID }
            self?.groups[groupID] = nil
            // stop observing messages in the room, good!
            DatabaseManager.shared.removeObserver(with: "conversations/\(groupID)")
        }
        
        /*
        DatabaseManager.shared.observeUserAdditionToGroup() { [weak self] groupID in
            DatabaseManager.shared.getGroup(with: groupID) { result in
                switch result {
                case .success(let group):
                    // self?.groups[group.id] = group
                    self?.groups.append(group)
//                    self?.groups.insert(group, at: 0)
                    DatabaseManager.shared.listenForMessages(in: group.id) { result in
                        switch result {
                        case .success(let message):
                            // find the index
                            // shouldn't take too long to find the index
  
                            if let index = self?.groups.firstIndex(where: { $0.id == group.id }) {
                                self?.groups[index].messages.append(message)
                            }
                            
                            // self?.groups[group.id] = group
                            
                        case .failure(_):
                            print("failed to get messages in group \(group.id)")
                        }
                    }
                    
                case .failure(_):
                    print("failed to get group with id \(groupID)")
                }
            }
            
        }
        */

        
        DatabaseManager.shared.observeInviteAcceptance() { [weak self] result in
            switch result {
            case .success(let groupID):
                self?.groups[groupID]?.pending = false 
                DatabaseManager.shared.listenForMessages(in: groupID) { result in
                    switch result {
                    case .success(let message):
                        self?.groups[groupID]?.messages.append(message)
                        
                    case .failure(_):
                        print("failed to get messages in group \(groupID)")
                    }
                }
            case .failure(_):
                print("error getting id of pending group invite")
            }
        }
        
        
        DatabaseManager.shared.observeRoomChange() { [weak self] result in
            switch result {
                
            case .success(let room):
                // stop listening for conversations in the previous room
                if let currentRoom = self?.currentRoom {
                    DatabaseManager.shared.removeMessagesObserver(currentRoom)
                }
                
                self?.currentRoom = room
                
                // remove old users
                self?.suggestedUsers = []
                
                // update the users
                DatabaseManager.shared.getUsers(in: room, completion: { result in
                    switch result {
                    case .success(let users):
                        self?.suggestedUsers = users
                    case .failure(_):
                        print("failed to get users in new room \(room)")
                    }
                    
                })
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}

extension AppStateModel {
    
    func queryUsersByArtistOrTrackName(_ terms: [String], completion: @escaping ([Message.ChatUserItem]) -> Void) {
        // clear previous result
        self.searchResults = []
        // remove ongoing observers
        DatabaseManager.shared.removeObserver(with: "User")
        // cancel search if it takes too long
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            DatabaseManager.shared.removeObserver(with: "User")
        }
        DatabaseManager.shared.queryUsersByArtistOrTrackName(terms) { results in
            // self?.searchResults = results
            completion(results)
            
        }
    }
}


//MARK: - Additional functions
