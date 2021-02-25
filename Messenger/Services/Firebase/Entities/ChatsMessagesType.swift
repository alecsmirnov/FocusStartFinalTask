//
//  ChatsMessagesType.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

enum ChatsMessagesType {
    case text(String)
}

// MARK: - Codable

extension ChatsMessagesType: Codable {
    private enum CodingKeys: String, CodingKey {
        case text
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let key = container.allKeys.first
        
        switch key {
        case .text:
            let text = try container.decode(String.self, forKey: .text)
            self = .text(text)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: container.codingPath, debugDescription: "unable to decode enum"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let text):
            try container.encode(text, forKey: .text)
        }
    }
}
