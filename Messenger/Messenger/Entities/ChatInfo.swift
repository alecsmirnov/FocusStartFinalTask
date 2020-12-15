//
//  ChatInfo.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

struct ChatInfo {
    let identifier: String
    let isGroup: Bool
    
    var group: GroupInfo?
    var companion: UserInfo?
    
    var latestMessage: MessageInfo?
    var unreadMessagesCount: Int?
}
