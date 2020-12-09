//
//  UsersChatsValue.swift
//  Messenger
//
//  Created by Admin on 09.12.2020.
//

import Foundation

struct UsersChatsValue {
    // MARK: Properties
    
    let userIdentifier: String
    
    private let creationTimestamp: TimeInterval
    
    // MARK: Initialization
    
    init(userIdentifier: String) {
        self.userIdentifier = userIdentifier
        
        creationTimestamp = Date().timeIntervalSince1970
    }
}

// MARK: - Codable

extension UsersChatsValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case userIdentifier = "user_identifier"
        case creationTimestamp = "creation_timestamp"
    }
}
