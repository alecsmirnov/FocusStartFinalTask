//
//  EmailValidation.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import Foundation

enum EmailValidation {
    static func isValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._-]+@[A-Z0-9a-z]+\\.[A-Za-z]{2,6}"
        let isValid = NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        
        return isValid
    }
}
