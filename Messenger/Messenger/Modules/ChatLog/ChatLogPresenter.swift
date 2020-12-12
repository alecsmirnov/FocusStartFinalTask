//
//  ChatLogPresenter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogPresenter: AnyObject {
    var sectionsCount: Int { get }
    var messagesCount: Int { get }
    
    func viewDidLoad(view: IChatLogView)
    func viewWillAppear()
    
    func messageAt(index: Int) -> ChatsMessagesValue
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatLogRouter?
    
    var receiver: UserInfo?
    var chatIdentifier: String?
    
    var messages = [ChatsMessagesValue]()
}

// MARK: - IChatLogPresenter

extension ChatLogPresenter: IChatLogPresenter {
    var sectionsCount: Int {
        return 1
    }
    
    var messagesCount: Int {
        return messages.count
    }
}

extension ChatLogPresenter {
    func viewDidLoad(view: IChatLogView) {
        view.sendMessageButtonAction = { [weak self] in
            guard let text = view.messageText,
                  let senderIdentifier = FirebaseAuthService.currentUser()?.uid,
                  let receiverIdentifier = self?.receiver?.identifier else { return }
            
            view.clearTextView()
            
            if self?.chatIdentifier == nil {
                print("create chat")
                self?.chatIdentifier = FirebaseDatabaseService.createChatBetween(userIdentifier1: senderIdentifier,
                                                                                 userIdentifier2: receiverIdentifier)
            } else {
                print("chat not nill")
            }
            
            if let chatIdentifier = self?.chatIdentifier {
                let message = ChatsMessagesValue(senderIdentifier: senderIdentifier,
                                              messageType: .text(text),
                                              timestamp: Date().timeIntervalSince1970,
                                              isRead: false)
                FirebaseDatabaseService.sendMessage(message, chatIdentifier: chatIdentifier)
            }
        }
    }
    
    func viewWillAppear() {
        if let receiver = receiver {
            let receiverName = "\(receiver.firstName) \(receiver.lastName ?? "")"
            
            viewController?.setTitle(text: receiverName)
        }
    }
    
    func messageAt(index: Int) -> ChatsMessagesValue {
        return messages[index]
    }
}

extension ChatLogPresenter: IChatLogInteractorOutput {
    func sendMessageFail() {
        
    }
    
    func addedMessage(_ message: ChatsMessagesValue) {
        messages.append(message)
        
        viewController?.reloadData()
    }
}
