//
//  ChatsMessagesValue.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

struct ChatsMessagesValue {
    let senderIdentifier: String
    
    let messageType: ChatsMessagesType
    let date: String
    let isRead: Bool
}

// MARK: - Codable

extension ChatsMessagesValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case senderIdentifier = "sender_identifier"
        
        case messageType = "message_type"
        case date
        case isRead = "is_read"
    }
}
