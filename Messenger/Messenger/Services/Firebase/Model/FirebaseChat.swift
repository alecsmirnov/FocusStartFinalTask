//
//  FirebaseChat.swift
//  Messenger
//
//  Created by Admin on 08.12.2020.
//

struct FirebaseChat {
    let chatIdentifier: String
    let userIdentifier: String
    
    var user: FirebaseUser
    var latestMessage: FirebaseMessage
}
