//
//  Conversation.swift
//  test-app2
//
//  Created by Yonatan Mamo on 07.05.22.
//

import Foundation

struct Conversation: Identifiable {
    let id: String
    let otherUserName: String
    let otherUserID: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
