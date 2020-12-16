//
//  FirebaseDatabaseUserStatusService.swift
//  Messenger
//
//  Created by Admin on 16.12.2020.
//

import FirebaseDatabase

enum FirebaseDatabaseUserStatusService {
    private static let databaseReference = Database.database().reference()
}

// MARK: - Public Editing Methods

extension FirebaseDatabaseUserStatusService {    
    static func setUserStatus(userIdentifier: String, isOnline: Bool) {
        let user = FirebaseDatabaseCoding.toDictionary(UsersStatusValue(isOnline: isOnline))
        
        databaseReference.child(Tables.usersStatus)
                         .child(userIdentifier)
                         .setValue(user)
    }
}

// MARK: - Public Observe Methods

extension FirebaseDatabaseUserStatusService {
    static func observeUserStatus(userIdentifier: String, completion: @escaping (Bool) -> Void) -> ObserverData {
        let userStatusReference = databaseReference.child(Tables.usersStatus)
                                                   .child(userIdentifier)
        let userStatusHandle = userStatusReference.observe(.childChanged) { snapshot in
            print("Observe: \(snapshot)")
            //guard let value = snapshot.value else { return }
            
            
        }
        
        return ObserverData(reference: userStatusReference, handle: userStatusHandle)
    }
}

// MARK: - Private Fetch Methods

extension FirebaseDatabaseUserStatusService {
    static func fetchUserStatus(userIdentifier: String, completion: @escaping (Bool?) -> Void) {
        databaseReference.child(Tables.usersStatus)
                          .child(userIdentifier)
                          .observeSingleEvent(of: .value) { snapshot in
            print("Fetch: \(snapshot)")
                
        }
    }
}
