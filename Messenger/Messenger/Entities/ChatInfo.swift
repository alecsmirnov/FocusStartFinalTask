//
//  ChatInfo.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import Foundation

struct LatestMessageInfo {
    let senderIdentifier: String
    let senderName: String
    
    let text: String
    let timestamp: TimeInterval
}

struct GroupInfo {
    var name: String
    var profileImageData: Data?
    
    let creatorIdentifier: String?
    
    var moderatorsIdentifiers: [String]?
}

struct ChatInfo {
    let identifier: String
    
    let isGroup: Bool
    var group: GroupInfo
    
    var latestMessage: LatestMessageInfo
    var unreadMessagesCount: Int?
}
