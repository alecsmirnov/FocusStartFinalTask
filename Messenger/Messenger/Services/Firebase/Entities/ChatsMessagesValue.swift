//
//  ChatsMessagesValue.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

struct ChatsMessagesValue {
    let senderIdentifier: String
    
    let messageType: ChatsMessagesType
    let timestamp: Double
    let isRead: Bool
}

// MARK: - Codable

extension ChatsMessagesValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case senderIdentifier = "sender_identifier"
        
        case messageType = "message_type"
        case timestamp
        case isRead = "is_read"
    }
}
