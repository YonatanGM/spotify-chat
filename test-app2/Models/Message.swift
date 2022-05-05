//
//  Message.swift
//  test-app2
//
//  Created by Yonatan Mamo on 01.05.22.
//

import MessageKit
import Foundation

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}


