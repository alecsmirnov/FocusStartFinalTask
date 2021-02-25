//
//  UsersChatsValue.swift
//  Messenger
//
//  Created by Admin on 09.12.2020.
//

import Foundation

struct UsersChatsLatestMessageValue: Codable {
    // MARK: Properties
    
    var identifier: String? {
        return info.identifier
    }
    
    var timestamp: TimeInterval {
        return info.timestamp        
    }
    
    // MARK: Additional Node
    
    private let info: Info
    
    // MARK: Initialization
    
    init(identifier: String? = nil, timestamp: TimeInterval) {
        info = Info(identifier: identifier, timestamp: timestamp)
    }
}

fileprivate struct Info: Codable {
    let identifier: String?
    let timestamp: TimeInterval
}
