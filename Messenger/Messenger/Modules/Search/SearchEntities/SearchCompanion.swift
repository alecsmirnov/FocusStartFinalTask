//
//  SearchCompanion.swift
//  Messenger
//
//  Created by Admin on 04.12.2020.
//

struct SearchCompanion {
    let userIdentifier: String
    
    let firstName: String
    let lastName: String?
    let profilePhotoURL: String?
    
    //let userName: String?
    //let email: String
    
    let chat: SearchChat?
}

// MARK: - Equatable

extension SearchCompanion: Equatable {
    static func ==(lhs: SearchCompanion, rhs: SearchCompanion) -> Bool {
        return lhs.userIdentifier == rhs.userIdentifier
    }
}
