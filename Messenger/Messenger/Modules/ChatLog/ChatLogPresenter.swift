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
    
    private var messages = [MessageInfo]()
    
    private var topInsertOffset = 0
    private var isViewAppear = false
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
        interactor?.fetchMessages()
    }
    
    func viewWillAppear() {
        interactor?.fetchChatTitleInfo()
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
        interactor?.sendMessage(messageType)
        viewController?.scrollToBottom()
    }
    
    func didReadMessageAt(index: Int) {
        interactor?.readMessage(messages[index])
    }
    
    func didPullToRefresh() {
        if !messages.isEmpty {
            interactor?.fetchPreviousMessages()
        }
    }
}

// MARK: - IChatLogInteractorOutput

extension ChatLogPresenter: IChatLogInteractorOutput {
    func fetchMessagesSuccess(_ messages: [MessageInfo]) {
        self.messages = messages
    }
    
    func fetchPreviousMessagesSuccess(_ previousMessages: [MessageInfo]) {
        messages.insert(contentsOf: previousMessages, at: 0)
        
        viewController?.reloadData()
        viewController?.endRefreshing()
    }
    
    func fetchPreviousMessagesFail() {
        viewController?.endRefreshing()
    }
    
    func fetchChatTitleInfoSuccess(title: String) {
        viewController?.setTitle(text: title)
    }
    
    func addedMessage(_ message: MessageInfo) {
        messages.append(message)
        
        viewController?.reloadData()
        //viewController?.insertNewRow()
        //viewController?.scrollToBottom()
    }
    
    func updateMessage(_ message: MessageInfo) {
//        if let index = messages.firstIndex(where: { $0.identifier == message.identifier }) {
//            messages[index] = message
//
//            // check if sender is not me and update
//
//            guard let identifier = FirebaseAuthService.currentUser()?.uid else { return }
//
//            if isViewAppear, message.senderIdentifier == identifier {
//                viewController?.updateRowAt(index: index)
//            }
//        }
    }
}
