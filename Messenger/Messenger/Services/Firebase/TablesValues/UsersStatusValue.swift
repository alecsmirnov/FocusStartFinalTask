//
//  UsersStatusValue.swift
//  Messenger
//
//  Created by Admin on 16.12.2020.
//

struct UsersStatusValue: Codable {
    // MARK: Properties
    
    var isOnline: Bool { info.isOnline }
    
    private let info: Info
    
    // MARK: Initialization
    
    init(isOnline: Bool) {
        info = Info(isOnline: isOnline)
    }
}

fileprivate struct Info {
    let isOnline: Bool
}

// MARK: - Codable

extension Info: Codable {
    private enum CodingKeys: String, CodingKey {
        case isOnline = "is_online"
    }
}
