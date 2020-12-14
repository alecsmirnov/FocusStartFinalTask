//
//  ChatsInfoGroupValue.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

struct ChatsInfoGroupValue {
    let name: String
    let photoURL: String?
    
    let creatorIdentifier: String
}

// MARK: - Codable

extension ChatsInfoGroupValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case photoURL = "photo_url"
        
        case creatorIdentifier = "creator_identifier"
    }
}
