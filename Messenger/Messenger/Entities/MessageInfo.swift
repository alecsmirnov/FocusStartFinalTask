//
//  MessageInfo.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//

import Foundation

struct MessageInfo {
    let identifier: String
    
    let senderIdentifier: String
    let type: ChatsMessagesType
    let isRead: Bool
    let timestamp: TimeInterval
}
