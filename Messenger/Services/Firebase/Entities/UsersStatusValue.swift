//
//  UsersStatusValue.swift
//  Messenger
//
//  Created by Admin on 16.12.2020.
//

import Foundation

struct UsersStatusValue: Codable {
    // MARK: Properties
    
    var isOnline: Bool {
        return info.isOnline
    }
    
    var timestamp: TimeInterval {
        return  info.timestamp
    }
    
    // MARK: Additional Node
    
    private let info: Info
    
    // MARK: Initialization
    
    init(isOnline: Bool, timestamp: TimeInterval) {
        info = Info(isOnline: isOnline, timestamp: timestamp)
    }
}

fileprivate struct Info {
    let isOnline: Bool
    let timestamp: TimeInterval
}

// MARK: - Codable

extension Info: Codable {
    private enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
        case timestamp
    }
}
