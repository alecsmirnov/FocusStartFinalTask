//
//  UsersChatsUnreadMessagesCountValue.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import Foundation

struct UsersChatsUnreadMessagesCountValue: Codable {
    // MARK: Properties
    
    var count: Int { info.count }
    var timestamp: TimeInterval { info.timestamp }
    
    // MARK: Additional Node
    
    private let info: Info
    
    // MARK: Initialization
    
    init(count: Int, timestamp: TimeInterval) {
        info = Info(count: count, timestamp: timestamp)
    }
}

fileprivate struct Info: Codable {
    let count: Int
    let timestamp: TimeInterval
}
