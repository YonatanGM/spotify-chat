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
    
}
