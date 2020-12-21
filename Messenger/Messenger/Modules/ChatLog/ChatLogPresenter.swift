//
//  ChatLogPresenter.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import Foundation

protocol IChatLogPresenter: AnyObject {
    var sectionsCount: Int { get }
    
    func viewDidLoad()
    func viewDidAppear()
    func viewDidDisappear()
    
    func sectionDate(section: Int) -> String
    func messagesCount(section: Int) -> Int
    
    func messageAt(section: Int, index: Int) -> MessageInfo?
    
    func didPressSendButton(messageType: ChatsMessagesType)
    func didReadMessageAt(section: Int, index: Int)
    func didPullToRefresh()
}

final class ChatLogPresenter {
    weak var viewController: IChatLogViewController?
    var interactor: IChatLogInteractor?
    var router: IChatLogRouter?
    
    var chat: ChatInfo?
    
    private let messagesService = MessagesGroupingService()
}

// MARK: - IChatLogPresenter

extension ChatLogPresenter: IChatLogPresenter {
    var sectionsCount: Int {
        return messagesService.sectionsCount
    }

    func viewDidLoad() {
        interactor?.fetchMessages()
        interactor?.observeMessages()
    }
    
    func viewDidAppear() {
        var unreadMessagesCount = 0
//        if let chatUnreadMessagesCount = chat?.unreadMessagesCount {
//            unreadMessagesCount = chatUnreadMessagesCount
//        }
//
        //viewController?.startFromRowAt(index: messages.count - unreadMessagesCount)
    }
    
    func viewDidDisappear() {
        
    }
    
    func sectionDate(section: Int) -> String {
        return messagesService.dateAt(section: section)?.dateString() ?? ""
    }
    
    func messagesCount(section: Int) -> Int {
        return messagesService.messagesCountAt(section: section)
    }
    
    func messageAt(section: Int, index: Int) -> MessageInfo? {
        return messagesService.messageAt(section: section, row: index)
    }
    
    func didPressSendButton(messageType: ChatsMessagesType) {
        interactor?.sendMessage(messageType)
        viewController?.scrollToBottom()
    }
    
    func didReadMessageAt(section: Int, index: Int) {
        if let message = messagesService.messageAt(section: section, row: index) {
            interactor?.readMessage(message)
        }
    }
    
    func didPullToRefresh() {
        interactor?.fetchPreviousMessages()
    }
}

// MARK: - IChatLogInteractorOutput

extension ChatLogPresenter: IChatLogInteractorOutput {
    func fetchMessagesSuccess(_ messages: [MessageInfo]) {
        self.messagesService.appendMessages(messages)
    }
    
    func fetchPreviousMessagesSuccess(_ previousMessages: [MessageInfo]) {
        messagesService.insertMessagesAtTop(previousMessages)
        
        viewController?.reloadData()
        viewController?.endRefreshing()
    }
    
    func fetchPreviousMessagesFail() {
        viewController?.endRefreshing()
    }
    
    func addedMessage(_ message: MessageInfo) {
        messagesService.appendMessage(message)
        
        viewController?.reloadData()
        //viewController?.insertNewRow()
        //viewController?.scrollToBottom()
    }

    func updateMessage(_ message: MessageInfo) {
        if let section = messagesService.sectionAt(date: Date(timeIntervalSince1970: message.timestamp).sortDate()) {
            let messages = messagesService.messagesAt(section: section)
    
            if let row = messages?.firstIndex(where: { $0.identifier == message.identifier }) {
                if !(message.isIncoming ?? true) {
                    viewController?.updateMessageAt(section: section, row: row)
                }
            }
        }
    }
}

// MARK: - Private Methods

private extension ChatLogPresenter {
    func setChatTitleInfo() {
//        guard let chat = chat else { return }
//
//        let title = "\(chat.companion.firstName) \(chat.companion.lastName ?? "")"
//
//        viewController?.setTitle(text: title)
    }
}
