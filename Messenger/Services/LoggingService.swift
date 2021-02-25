//
//  LoggingService.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Foundation
import os

enum LoggingService {
    enum CategoryType: String {
        case launch
        case login
        case registration
        case authorization
        case chats
        case dataReceiving
        case search
        case database
    }
    
    enum LayerType: String {
        case view
        case viewController
        case interactor
        case presenter
        case router
        case none
    }
    
    enum RecordType: String  {
        case info
        case alert
        case warning
        case error
    }
}

// MARK: - Methods

extension LoggingService {
    static func log(category: CategoryType, layer: LayerType, type: RecordType, with message: String?) {
        if let subsystem = Bundle.main.bundleIdentifier {
            let logger = Logger(subsystem: subsystem, category: category.rawValue)
            
            let recordForm = "\nLayer:   \(layer.rawValue)\nType:    \(type.rawValue)"
            let messageForm = (message != nil) ? "\nMessage: \(message ?? "")" : ""
            
            logger.log("\(recordForm + messageForm)")
        }
    }
}
