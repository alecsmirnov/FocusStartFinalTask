//
//  Timestamp.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import Foundation

enum Timestamp {
    static let key = "timestamp"
    static let clearValue = -1.0
    
    static var current: TimeInterval {
        return Date().timeIntervalSince1970
    }
}
