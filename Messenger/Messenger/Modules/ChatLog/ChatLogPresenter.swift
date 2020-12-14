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
    func viewDidAppear()
    
    func didPressSendButton(messageType: ChatsMessagesType)
    
    func messageAt(index: Int) -> ChatsMessagesValue
    func displayMessageAt(index: Int)
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatLogRouter?
    
    var chatIdentifier: String?
    var companion: UserInfo?
    
    private var isViewAppear = false

    private var messages = [Message]()
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
        isViewAppear = true
        
        //viewController?.reloadData()
        
        if let companion = companion {
            let receiverName = "\(companion.firstName) \(companion.lastName ?? "")"
            
            viewController?.setTitle(text: receiverName)
        }
    }
    
    func viewDidAppear() {

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
        return messages[index].data
    }
    
    func displayMessageAt(index: Int) {
        if let chatIdentifier = chatIdentifier {
            //print(index)
            
            interactor?.readMessage(messages[index], chatIdentifier: chatIdentifier)
        }
    }
}

// MARK: - IChatLogInteractorOutput

extension ChatLogPresenter: IChatLogInteractorOutput {
    func addedMessage(_ message: Message) {
        messages.append(message)
        
        if isViewAppear {
            viewController?.insertNewRow()
            //viewController?.startFromRowAt(index: 10)
            //viewController?.scrollToBottom()
        }
    }
    
    func updateMessage(_ message: Message) {
        if let index = messages.firstIndex(where: { $0.identifier == message.identifier }) {
            messages[index] = message
            
            // check if sender is not me and update
            
            guard let identifier = FirebaseAuthService.currentUser()?.uid else { return }
            
            if isViewAppear, message.data.senderIdentifier == identifier {
                viewController?.updateRowAt(index: index)
            }
        }
    }
}
