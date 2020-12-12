//
//  KeyValueService.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Foundation

enum KeyValueService<T> {
    static func setValue(_ value: T?, forKey key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    static func getValue(forKey key: String) -> T? {
        return UserDefaults.standard.object(forKey: key) as? T
    }
}
