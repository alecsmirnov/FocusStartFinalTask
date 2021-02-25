//
//  Date+sortDate.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import Foundation

extension Date {
    func sortDate() -> Date {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        return dateFormatter.date(from: dateFormatter.string(from: self))!
    }
}
