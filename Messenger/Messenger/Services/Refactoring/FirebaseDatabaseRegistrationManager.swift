//
//  FirebaseDatabaseRegistrationManager.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//

import FirebaseDatabase

final class FirebaseDatabaseRegistrationManager {
    private let databaseReference = Database.database().reference()
}

extension FirebaseDatabaseRegistrationManager {
    func addUser(_ user: UsersValue, identifier: String) {
        if let userRecord = FirebaseDatabaseService.encodableToDictionary(user) {
            databaseReference.child(Tables.users)
                             .child(identifier)
                             .child("info")
                             .setValue(userRecord)
        }
    }
}
