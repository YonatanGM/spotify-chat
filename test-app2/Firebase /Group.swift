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
    
    var indexOfLastSeen: Int = 0
    
    var unseenCount: Int {
        print(indexOfLastSeen)
        return max(0, messages.endIndex - indexOfLastSeen - 1)
    }
    
}
