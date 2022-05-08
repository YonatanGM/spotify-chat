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
    

    
    @Published private(set) var users = [ChatUser]()
    @Published private(set) var conversations = [Conversation]()
    @Published var messages = [String: [Message]]()
 
    @Published private(set) var isSignedIn: Bool = AuthManager.shared.isSignedIn
    @Published private(set) var isSigningIn: Bool = false
    
    
    var currentChatUser: ChatUser? {
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let currentUserName = Auth.auth().currentUser?.displayName else {
            return nil
        }
        return ChatUser(id: currentUserID, name: currentUserName, email: Auth.auth().currentUser?.email, profile_picture: Auth.auth().currentUser?.photoURL?.absoluteString)
    }
    
    
    init() {

        if isSignedIn {
            listenForConversations()
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
    
    
    private func loadMatchingUsers() {
        // match making algorithm
    }


}



//MARK: - Conversations


extension AppStateModel {
    
    var hasConversations: Bool {
        !conversations.isEmpty
    }
    
    private func listenForConversations() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        print("starting conversation fetch...")

        DatabaseManager.shared.getAllConversations(for: currentUserID, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversations):
                print("successfully got conversations")
                
                DispatchQueue.main.async {
                    strongSelf.conversations = conversations
                    
                    // new convos
                    conversations.filter { !strongSelf.messages.keys.contains($0.id) }.forEach { newConversation in
                        strongSelf.listenForMessages(in: newConversation.id)
                        
                    }
                }
                
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
        })
    }
    
    
    func conversationExists(with otherUser: ChatUser,  completion: @escaping (Result<String?, Error>) -> Void) {
        // check if conversation is already in current conversations
       if let targetConversation = conversations.first(where: {
            $0.otherUserID == otherUser.id
       }) {
           completion(.success(targetConversation.id))
       } else {
            // check in database
            DatabaseManager.shared.conversationExists(with: otherUser.id) { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
    
    
    

    private func listenForMessages(in conversation: String) {
        DatabaseManager.shared.getAllMessagesForConversation(with: conversation, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                print("success in getting messages: \(messages)")
                guard !messages.isEmpty else {
                    print("messages are empty")
                    return
                }
                self?.messages[conversation] = messages

            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }
    
    


}
