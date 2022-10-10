//
//  Group.swift
//  test-app2
//
//  Created by Yonatan Mamo on 11.09.22.
//

import Foundation

struct Group {
    let id: String
    var name: String
    let admin: String
    var users: [UserInfo]
    
    var pending = false
    var messages = [Message.ChatMessageItem]()
    
    var lastSeenMessageID = "-" // should be lexographically smaller than any child by auto id key 
    var unseenCount: UInt = 0
    
    // Direct messaging 
    var recipient: UserInfo?

    
}

// Direct message

extension Group {
    
    var isDm: Bool {
        recipient != nil
    }
    
    var otherUser: UserInfo? {
        guard let currentUserID = AuthManager.shared.currentUser?.uid else {
            return nil
        }
        if currentUserID == self.admin {
            return self.recipient
        } else {
            return self.users.first { $0.id == self.admin }
        }
    }
}
