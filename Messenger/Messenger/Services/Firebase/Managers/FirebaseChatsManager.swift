//
//  FirebaseChatsManager.swift
//  Messenger
//
//  Created by Admin on 14.12.2020.
//

import Foundation

final class FirebaseChatsManager {
    private var observedChatsData = [String: [ObserverData]]()
}

// MARK: - Public Editing Methods

extension FirebaseChatsManager {
    func clearChat(chatIdentifier: String, userIdentifier: String) {
        FirebaseChatsService.clearChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
    }
    
    func removeChat(chatIdentifier: String, userIdentifier: String) {
        if let chatObservers = observedChatsData[chatIdentifier] {
            chatObservers.forEach { $0.remove() }
        }
        
        FirebaseChatsService.removeChat(chatIdentifier: chatIdentifier, userIdentifier: userIdentifier)
    }
}

// MARK: - Public Observe Methods

extension FirebaseChatsManager {
    func observeLoadedChats(userIdentifier: String,
                            latestUpdateTime: TimeInterval,
                            chats: [ChatInfo],
                            pairChatUpdated: @escaping (String, UserInfo) -> Void,
                            chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                            chatUnreadMessagesUpdated: @escaping (String, Int) -> Void,
                            chatOnlineStatusUpdate: @escaping (String, Bool) -> Void) {
        chats.forEach { chat in
            FirebaseUserService.fetchUserWithUpdateTime(userIdentifier: chat.companion.identifier,
                                                        latestUpdateTime: latestUpdateTime) { companion in
                if let companion = companion {
                    pairChatUpdated(chat.identifier, companion)
                }
            }

            FirebaseChatsService.fetchUserChatLatestMessageWithUpdateTime(
                chatIdentifier: chat.identifier,
                userIdentifier: userIdentifier,
                latestUpdateTime: latestUpdateTime
            ) { latestMessage in
                if let latestMessage = latestMessage {
                    chatLatestMessageUpdated(chat.identifier, latestMessage)
                }
            }

            FirebaseChatsService.fetchChatUnreadMessagesCountWithUpdateTime(
                chatIdentifier: chat.identifier,
                userIdentifier: userIdentifier,
                latestUpdateTime: latestUpdateTime
            ) { count in
                if let count = count {
                    chatUnreadMessagesUpdated(chat.identifier, count)
                }
            }
            
            FirebaseUserService.fetchUserStatus(userIdentifier: chat.companion.identifier) { isOnline in
                if let isOnline = isOnline {
                    chatOnlineStatusUpdate(chat.identifier, isOnline)
                }
            }
            
            observePairChat(chatIdentifier: chat.identifier,
                            userIdentifier: userIdentifier,
                            companionIdentifier: chat.companion.identifier,
                            pairChatUpdated: pairChatUpdated,
                            chatLatestMessageUpdated: chatLatestMessageUpdated,
                            chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
            
            let userStatusObserver = FirebaseUserService.observeUserStatus(
                userIdentifier: chat.companion.identifier
            ) { isOnline in
                chatOnlineStatusUpdate(chat.identifier, isOnline)
            }
            
            observedChatsData[chat.identifier] = (observedChatsData[chat.companion.identifier] ?? []) +
                                                 [userStatusObserver]
        }
    }
    
    func observeChats(userIdentifier: String,
                      latestUpdateTime: TimeInterval,
                      chatAddedCompletion: @escaping (ChatInfo) -> Void,
                      pairChatUpdated: @escaping (String, UserInfo) -> Void,
                      chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                      chatUnreadMessagesUpdated: @escaping (String, Int) -> Void,
                      chatOnlineStatusUpdate: @escaping (String, Bool) -> Void) {
        FirebaseChatsService.observeAddedChats(
            for: userIdentifier,
            latestUpdateTime: latestUpdateTime
        ) { [weak self] chat in
            chatAddedCompletion(chat)
            
            self?.observePairChat(chatIdentifier: chat.identifier,
                                  userIdentifier: userIdentifier,
                                  companionIdentifier: chat.companion.identifier,
                                  pairChatUpdated: pairChatUpdated,
                                  chatLatestMessageUpdated: chatLatestMessageUpdated,
                                  chatUnreadMessagesUpdated: chatUnreadMessagesUpdated)
            
            let userStatusObserver = FirebaseUserService.observeUserStatus(
                userIdentifier: chat.companion.identifier
            ) { isOnline in
                chatOnlineStatusUpdate(chat.identifier, isOnline)
            }
            
            self?.observedChatsData[chat.identifier] = (self?.observedChatsData[chat.companion.identifier] ?? []) +
                                                       [userStatusObserver]
        }
    }
    
    func observeRemovedChats(for userIdentifier: String, completion: @escaping (String) -> Void) {
        FirebaseChatsService.observeRemovedChats(for: userIdentifier, completion: completion)
    }
}

// MARK: - Private Observe Methods

private extension FirebaseChatsManager {
    func observePairChat(chatIdentifier: String,
                         userIdentifier: String,
                         companionIdentifier: String,
                         pairChatUpdated: @escaping (String, UserInfo) -> Void,
                         chatLatestMessageUpdated: @escaping (String, MessageInfo?) -> Void,
                         chatUnreadMessagesUpdated: @escaping (String, Int) -> Void) {
        let companionObserver = FirebaseUserService.observeUserChanged(
            userIdentifier: companionIdentifier
        ) { companion in
            pairChatUpdated(chatIdentifier, companion)
        }
        
        let latestMessageObserver = FirebaseChatsService.observeLatestMessagesChanged(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier
        ) { message in
            chatLatestMessageUpdated(chatIdentifier, message)
        }
        
        let unreadMessagesObserver = FirebaseChatsService.observeUnreadMessagesChanged(
            chatIdentifier: chatIdentifier,
            userIdentifier: userIdentifier
        ) { count in
            chatUnreadMessagesUpdated(chatIdentifier, count)
        }
        
        let observers = [companionObserver, latestMessageObserver, unreadMessagesObserver]
        
        observedChatsData[chatIdentifier] = (observedChatsData[chatIdentifier] ?? []) + observers
    }
}
