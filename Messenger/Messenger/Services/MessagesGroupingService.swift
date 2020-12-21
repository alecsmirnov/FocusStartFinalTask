//
//  MessagesGroupingService.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import Foundation

final class MessagesGroupingService {
    // MARK: Properties
    
    var sectionsCount: Int {
        return indices.count
    }
    
    private var indices = [Date]()
    private var groupedMessages = [Date: [MessageInfo]]()
}

// MARK: - Public Methods

extension MessagesGroupingService {
    func appendMessage(_ message: MessageInfo) {
        let key = Date(timeIntervalSince1970: message.timestamp).sortDate()

        if groupedMessages[key] != nil {
            groupedMessages[key]?.append(message)
        } else {
            groupedMessages[key] = [message]
            
            indices.append(key)
            indices.sort()
        }
    }
    
    func appendMessages(_ messages: [MessageInfo]) {
        let newGroupedMessages = MessagesGroupingService.groupMessages(messages)
        
        newGroupedMessages.forEach { key, value in
            if groupedMessages[key] != nil {
                groupedMessages[key]?.append(contentsOf: value)
            } else {
                groupedMessages[key] = value
                
                indices.append(key)
                indices.sort()
            }
        }
    }
    
    func insertMessagesAtTop(_ messages: [MessageInfo]) {
        let newGroupedMessages = MessagesGroupingService.groupMessages(messages)
        
        newGroupedMessages.forEach { key, value in
            if groupedMessages[key] != nil {
                groupedMessages[key]?.insert(contentsOf: value, at: 0)
            } else {
                groupedMessages[key] = value
                
                indices.append(key)
                indices.sort()
            }
        }
    }
    
    func sectionAt(timestamp: TimeInterval) -> Int? {
        return indices.firstIndex(of: Date(timeIntervalSince1970: timestamp).sortDate())
    }
    
    func sectionAt(date: Date) -> Int? {
        return indices.firstIndex(of: date)
    }
    
    func messagesCountAt(section: Int) -> Int {
        return messagesAt(section: section)?.count ?? 0
    }
    
    func messageAt(section: Int, row: Int) -> MessageInfo? {
        return messagesAt(section: section)?[row]
    }
    
    func messagesAt(section: Int) -> [MessageInfo]? {
        return groupedMessages[indices[section]]
    }
    
    func messagesAt(date: Date) -> [MessageInfo]? {
        return groupedMessages[date]
    }
    
    func dateAt(section: Int) -> Date? {
        return indices[section]
    }
}

// MARK: - Private Methods

private extension MessagesGroupingService {
    static func groupMessages(_ messages: [MessageInfo]) -> [Date: [MessageInfo]] {
        return Dictionary(grouping: messages) { Date(timeIntervalSince1970: $0.timestamp).sortDate() }
    }
}
