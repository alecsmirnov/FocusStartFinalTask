//
//  FirebaseDatabaseService.swift
//  Messenger
//
//  Created by Admin on 24.11.2020.
//

import FirebaseDatabase

enum Tables {
    static let users = "users"
    
    static let chatsMessages = "chats_messages"
    static let chatsMembers = "chats_members"
    static let chatsInfo = "chats_info"
    static let chatsInfoGroup = "chats_info_group"
    
    static let usersChats = "users_chats"
    static let usersChatsMessages = "users_chats_messages"
    static let usersChatsLatestMessages = "users_chats_latest_messages"
    static let usersChatsUnread = "users_chats_unread_messages_count"
}

enum FirebaseDatabaseService {
    private static let databaseReference = Database.database().reference()
    
    static func addUser(_ user: UsersValue, identifier: String) {
        if let userRecord = FirebaseDatabaseService.encodableToDictionary(user) {
            databaseReference.child(Tables.users)
                             .child(identifier)
                             .child("info")
                             .setValue(userRecord)
        }
    }
}

// MARK: - Helpers

extension FirebaseDatabaseService {
    static func encodableToDictionary<T>(_ data: T) -> [String: Any]? where T: Encodable {
        var dictionary: [String: Any]?
        
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(data)
            let dictionaryData = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            
            dictionary = dictionaryData as? [String: Any]
        } catch let error {
            LoggingService.log(category: .database, layer: .none, type: .error, with: error.localizedDescription)
        }
        
        return dictionary
    }
    
    static func dictionaryToDecodable<T>(_ dictionary: [String: Any], type: T.Type) -> T? where T: Decodable {
        var jsonType: T?
        
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
            
            jsonType = try jsonDecoder.decode(T.self, from: jsonData)
        } catch let error {
            LoggingService.log(category: .database, layer: .none, type: .error, with: error.localizedDescription)
        }
        
        return jsonType
    }
}
