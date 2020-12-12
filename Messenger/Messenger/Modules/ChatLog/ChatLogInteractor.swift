//
//  ChatLogInteractor.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogInteractor: AnyObject {
    func sendMessage(text: String, from fromIdentifier: String, to toIdentifier: String)
    
//    func fetchMessages()
    func observeMessages(for chatIdentifier: String)
}

protocol IChatLogInteractorOutput: AnyObject {
    func sendMessageFail()
    
    func addedMessage(_ message: ChatsMessagesValue)
}

final class ChatLogInteractor {
    weak var presenter: IChatLogInteractorOutput?
}

// MARK: - IChatLogInteractor

extension ChatLogInteractor: IChatLogInteractor {
    func sendMessage(text: String, from fromIdentifier: String, to toIdentifier: String) {
        let message = ChatsMessagesValue(senderIdentifier: fromIdentifier,
                                      messageType: .text(text),
                                      timestamp: Date().timeIntervalSince1970,
                                      isRead: false)
        
//        FirebaseDatabaseService.send(message: message, to: toIdentifier) { error in
//            if error == nil {
//                print("send: \(text)")
//            } else {
//                print("fail to send: \(text)")
//            }
//        }
    }
    
    func observeMessages(for chatIdentifier: String) {
//        FirebaseDatabaseService.observeMessages(for: chatIdentifier) { [weak self] message in
//            self?.presenter?.addedMessage(message)
//        }
    }
}
