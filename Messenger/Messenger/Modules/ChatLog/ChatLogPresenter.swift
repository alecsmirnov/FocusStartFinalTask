//
//  ChatLogPresenter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Dispatch

protocol IChatLogPresenter: AnyObject {
    var sectionsCount: Int { get }
    var messagesCount: Int { get }
    
    func viewDidLoad()
    func viewWillAppear()
    
    func didPressSendButton(messageType: ChatsMessagesType)
    
    func messageAt(index: Int) -> ChatsMessagesValue
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatLogRouter?
    
    var chatIdentifier: String?
    var companion: UserInfo?
    
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
    func viewDidLoad() {
        if let chatIdentifier = chatIdentifier {
            interactor?.observeMessages(chatIdentifier: chatIdentifier)
        }
    }
    
    func viewWillAppear() {
        if let companion = companion {
            let receiverName = "\(companion.firstName) \(companion.lastName ?? "")"
            
            viewController?.setTitle(text: receiverName)
        }
    }
    
    func didPressSendButton(messageType: ChatsMessagesType) {
        if chatIdentifier == nil {
            if let companionIdentifier = companion?.identifier {
                chatIdentifier = interactor?.createChat(withUser: companionIdentifier)
            }
        }
        
        if let chatIdentifier = chatIdentifier {
            interactor?.sendMessage(messageType, toChat: chatIdentifier)
        }
    }
    
    func messageAt(index: Int) -> ChatsMessagesValue {
        return messages[index]
    }
}

// MARK: - IChatLogInteractorOutput

extension ChatLogPresenter: IChatLogInteractorOutput {   
    func addedMessage(_ message: ChatsMessagesValue) {
        messages.append(message)
        
        // TODO: add new row
        self.viewController?.reloadData()
    }
}
