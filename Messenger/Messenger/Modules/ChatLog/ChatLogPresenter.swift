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
    
    func messageAt(index: Int) -> MessageInfo
    
    func didPressSendButton(messageType: ChatsMessagesType)
    func didReadMessageAt(index: Int)
    func didPullToRefresh()
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatLogRouter?
    
    var chat: ChatInfo?
    
    private var messages = [MessageInfo]()
    
    private var topInsertOffset = 0
    private var isViewAppear = false
}

extension ChatLogPresenter {
    var companion: UserInfo? {
        get { chat?.companion }
        set { chat = interactor?.registerPairChat(with: newValue) }
    }
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
        if let chat = chat {
            interactor?.observeMessages(chatIdentifier: chat.identifier)
        }
    }
    
    func viewWillAppear() {
        guard let chat = chat else { return }
        
        if !chat.isGroup {
            
        } else {
            if let companion = chat.companion {
                let receiverName = "\(companion.firstName) \(companion.lastName ?? "")"
                
                viewController?.setTitle(text: receiverName)
            }
        }
    }
    
    func viewDidAppear() {
        var unreadMessagesCount = 0
//        if let chatUnreadMessagesCount = chat?.unreadMessagesCount {
//            unreadMessagesCount = chatUnreadMessagesCount
//        }
//
        viewController?.startFromRowAt(index: messages.count - unreadMessagesCount)
    }
    
    func messageAt(index: Int) -> MessageInfo {
        return messages[index]
    }
    
    func didPressSendButton(messageType: ChatsMessagesType) {
        if let chat = chat {
            interactor?.sendMessage(messageType, to: chat)
        }
    }
    
    func didReadMessageAt(index: Int) {
        //if let chatIdentifier = chatIdentifier {
            //print(index)
         //
        //    interactor?.readMessage(messages[index], chatIdentifier: chatIdentifier)
        //}
    }
    
    func didPullToRefresh() {
        if let chatIdentifier = chat?.identifier {
            if !messages.isEmpty {
                interactor?.loadLastMessages(chatIdentifier: chatIdentifier,
                                             topMessageIdentifier: messages[0].identifier)
            }
        }
    }
}

// MARK: - IChatLogInteractorOutput

extension ChatLogPresenter: IChatLogInteractorOutput {
    func addedMessage(_ message: MessageInfo) {
        messages.append(message)
        
        viewController?.reloadData()
        //viewController?.insertNewRow()
        //viewController?.scrollToBottom()
    }
    
    func updateMessage(_ message: MessageInfo) {
        if let index = messages.firstIndex(where: { $0.identifier == message.identifier }) {
            messages[index] = message
            
            // check if sender is not me and update
            
            guard let identifier = FirebaseAuthService.currentUser()?.uid else { return }
            
            if isViewAppear, message.senderIdentifier == identifier {
                viewController?.updateRowAt(index: index)
            }
        }
    }
    
    func addedPreviousMessage(_ message: MessageInfo) {
        messages.insert(message, at: topInsertOffset)
        topInsertOffset += 1
        
        viewController?.reloadData()
        viewController?.endRefreshing()
    }
}
