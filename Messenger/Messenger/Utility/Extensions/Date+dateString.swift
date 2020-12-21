//
//  Date+dateString.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import Foundation

extension Date {
    func dateString() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM d, yyyy"

        return dateFormatter.string(from: self)
    }
}
