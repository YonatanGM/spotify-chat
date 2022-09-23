//
//  Group.swift
//  test-app2
//
//  Created by Yonatan Mamo on 11.09.22.
//

import Foundation
struct Group {
    let id: String
    let name: String
    let admin: String
    let users: [UserInfo]
    
    var pending = false 
    var messages = [Message.ChatMessageItem]()
    var genres_display = [String]()
    
}
