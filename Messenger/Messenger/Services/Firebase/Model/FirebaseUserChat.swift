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
    
    private let creationTimestamp: String
    
    // MARK: Initialization
    
    init(userIdentifier: String) {
        self.userIdentifier = userIdentifier
        
        creationTimestamp = Date().timeIntervalSince1970.description
    }
}

// MARK: - Codable

extension UsersChatsValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case creationTimestamp = "creation_timestamp"
        case userIdentifier = "user_identifier"
    }
}