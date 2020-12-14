//
//  ChatInfo.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import Foundation

struct GroupInfo {
    let creatorIdentifier: String
    
    var name: String
    var profileImageData: Data?
    var moderatorsIdentifiers: [String]?
}

struct ChatInfo {
    let identifier: String
    let isGroup: Bool
    
    var group: GroupInfo?
    var companion: UserInfo?
    
    var latestMessage: LatestMessageInfo?
    var unreadMessagesCount: Int?
}
