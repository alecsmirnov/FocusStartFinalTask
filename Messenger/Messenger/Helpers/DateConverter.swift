//
//  DateConverter.swift
//  Messenger
//
//  Created by Admin on 04.12.2020.
//

import Foundation

enum DateConverter {
    private static let storeDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        dateFormatter.locale = .current
        
        return dateFormatter
    }()
}

// MARK: - Methods

extension DateConverter {
    static func dateToString(_ date: Date) -> String {
        return storeDateFormatter.string(from: date)
    }
    
    static func stringToDate(_ string: String) -> Date? {
        return storeDateFormatter.date(from: string)
    }
}

extension DateConverter {
    static func dateToChatLatestMessageString(_ date: Date) -> String {
        let isCurrentWeek = Calendar.current.isDate(Date(), equalTo: date, toGranularity: .weekOfYear)
        let dateFormatter = DateFormatter()
        
        if isCurrentWeek {
            dateFormatter.dateFormat = "EEEE"
        } else {
            dateFormatter.dateFormat = "dd.MM.yy"
        }
        
        return dateFormatter.string(from: date)
    }
}
