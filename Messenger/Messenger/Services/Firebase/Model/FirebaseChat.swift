//
//  FirebaseChat.swift
//  Messenger
//
//  Created by Admin on 08.12.2020.
//

import Foundation

struct FirebaseChat {
    let chatIdentifier: String
    let userIdentifier: String
    
    var user: UsersValue
    var latestMessage: ChatsMessagesValue
    
    var imageData: Data?
}
