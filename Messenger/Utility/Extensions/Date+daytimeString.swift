//
//  Date+daytimeString.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import Foundation

extension Date {
    func daytimeString() -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: self)
    }
}
