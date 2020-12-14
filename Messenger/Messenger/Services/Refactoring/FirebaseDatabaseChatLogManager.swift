//
//  FirebaseDatabaseChatLogManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import FirebaseDatabase

final class FirebaseDatabaseChatLogManager {
    private let databaseReference = Database.database().reference()
}

extension FirebaseDatabaseChatLogManager {
    func createPairChatBetween(user userIdentifier1: String, andUser userIdentifier2: String) -> String {
        let chatIdentifier = FirebaseDatabaseChatLogManager.getPairChatIdentifier(userIdentifier1: userIdentifier1,
                                                                                  userIdentifier2: userIdentifier2)
        
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier1)
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: userIdentifier2)
        defineGroupChatStatus(chatIdentifier: chatIdentifier, isGroup: false)
        
        return chatIdentifier
    }
    
    func createGroupChat(creatorIdentifier: String, name: String, membersIdentifiers: [String] = []) -> String? {
        guard let chatIdentifier = databaseReference.child(Tables.chatsMessages).childByAutoId().key else {
            return nil
        }
        
        addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: creatorIdentifier)
        defineGroupChatStatus(chatIdentifier: chatIdentifier, isGroup: true)
        setGroupChatInfo(chatIdentifier: chatIdentifier, creatorIdentifier: creatorIdentifier, name: name)
        
        membersIdentifiers.forEach { memberIdentifier in
            addChatMember(chatIdentifier: chatIdentifier, memberIdentifier: memberIdentifier)
        }
        
        return chatIdentifier
    }
    
    func addChatMember(chatIdentifier: String, memberIdentifier: String) {
        databaseReference.child(Tables.chatsMembers)
                         .child(chatIdentifier)
                         .child(memberIdentifier)
                         .setValue(true)

        databaseReference.child(Tables.usersChats)
                         .child(memberIdentifier)
                         .child(chatIdentifier)
                         .child("timestamp")
                         .setValue(Date().timeIntervalSince1970)
    }
}

// MARK: - Private Methods

private extension FirebaseDatabaseChatLogManager {
    func defineGroupChatStatus(chatIdentifier: String, isGroup: Bool) {
        databaseReference.child(Tables.chatsInfo)
                         .child(chatIdentifier)
                         .setValue(isGroup)
    }
    
    func setGroupChatInfo(chatIdentifier: String, creatorIdentifier: String, name: String, imagePath: String? = nil) {
        
        let chatsInfoGroupValue = ChatsInfoGroupValue(name: name,
                                                      photoURL: imagePath,
                                                      creatorIdentifier: creatorIdentifier)
        let value = FirebaseDatabaseService.encodableToDictionary(chatsInfoGroupValue)
        
        databaseReference.child(Tables.chatsInfoGroup)
                         .child(chatIdentifier)
                         .setValue(value)
    }
}

// MARK: - Helper Methods

private extension FirebaseDatabaseChatLogManager {
    static func getPairChatIdentifier(userIdentifier1: String, userIdentifier2: String) -> String {
        let chatIdentifier = (userIdentifier1 < userIdentifier2) ? userIdentifier1 + userIdentifier2 :
                                                                   userIdentifier2 + userIdentifier1
        return chatIdentifier
    }
}
