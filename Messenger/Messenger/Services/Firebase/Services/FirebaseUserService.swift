//
//  FirebaseUserService.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import FirebaseDatabase

enum FirebaseUserService {
    enum UsersSearchKey: String {
        case name = "info/queryable_name"
        case userName = "info/queryable_user_name"
        case email = "info/email"
    }
    
    private enum Constants {
        static let anyCharacterValue = "\u{f8ff}"
    }
    
    private static let databaseReference = Database.database().reference()
}

// MARK: - Public Editing Methods

extension FirebaseUserService {
    static func addUser(_ user: UsersValue, identifier: String) {
        updateUser(user, identifier: identifier)
        setUserStatus(userIdentifier: identifier, isOnline: true)
    }
    
    static func updateUser(_ user: UserInfo) {
        let userValue = userToUserValue(user)
        
        updateUser(userValue, identifier: user.identifier)
    }
    
    static func updateUser(_ user: UsersValue, identifier: String) {
        if let userRecord = FirebaseDatabaseCoding.toDictionary(user) {
            databaseReference.child(Tables.users).child(identifier).setValue(userRecord)
        }
    }
    
    static func setUserStatus(userIdentifier: String, isOnline: Bool) {
        let userValue = UsersStatusValue(isOnline: isOnline, timestamp: Timestamp.current)
        let user = FirebaseDatabaseCoding.toDictionary(userValue)
        
        databaseReference.child(Tables.usersStatus).child(userIdentifier).setValue(user)
    }
}

// MARK: - Public Observe Methods

extension FirebaseUserService {
    static func observeUserChanged(
        userIdentifier: String,
        completion: @escaping (UserInfo) -> Void
    ) -> ObserverData {
        let userReference = databaseReference.child(Tables.users).child(userIdentifier)
        let userHandle = userReference.observe(.childChanged) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let userValue = FirebaseDatabaseCoding.fromDictionary([snapshot.key: value], type: UsersValue.self)
            else {
                return
            }
            
            completion(userValueToUser(userIdentifier: userIdentifier, userValue: userValue))
        }
        
        return ObserverData(reference: userReference, handle: userHandle)
    }
    
    static func observeUserStatus(userIdentifier: String, completion: @escaping (Bool) -> Void) -> ObserverData {
        let userStatusReference = databaseReference.child(Tables.usersStatus).child(userIdentifier)
        let userStatusHandle = userStatusReference.observe(.childChanged) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let status = FirebaseDatabaseCoding.fromDictionary([snapshot.key: value], type: UsersStatusValue.self)
            else {
                return
            }

            completion(status.isOnline)
        }
        
        return ObserverData(reference: userStatusReference, handle: userStatusHandle)
    }
}

// MARK: - Public Fetch Methods

extension FirebaseUserService {
    static func fetchUsers(completion: @escaping ([UserInfo]?) -> Void) {
        fetchUsersValues { usersValues in
            guard let usersValues = usersValues else {
                completion(nil)
                
                return
            }
            
            let users = usersValues.map { userValueToUser(userIdentifier: $0, userValue: $1) }
            
            completion(users)
        }
    }
    
    static func fetchUsersValues(completion: @escaping ([String: UsersValue]?) -> Void) {
        databaseReference.child(Tables.users).observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let usersValues = FirebaseDatabaseCoding.fromDictionary(value,type: [String: UsersValue].self)
            else {
                completion(nil)
                
                return
            }
            
            completion(usersValues)
        }
    }
    
    static func fetchUsers(
        by parameter: String,
        key: UsersSearchKey,
        completion: @escaping ([String: UsersValue]?) -> Void
    ) {
        let queryableParameter = parameter.lowercased()
        
        databaseReference
            .child(Tables.users)
            .queryOrdered(byChild: key.rawValue)
            .queryStarting(atValue: queryableParameter)
            .queryEnding(atValue: queryableParameter + Constants.anyCharacterValue)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let usersValues = FirebaseDatabaseCoding.fromDictionary(value, type: [String: UsersValue].self)
            else {
                completion(nil)
                
                return
            }
            
            completion(usersValues)
        }
    }
    
    static func fetchUser(userIdentifier: String, completion: @escaping (UserInfo?) -> Void) {
        fetchUserValue(userIdentifier: userIdentifier) { userValue in
            guard let userValue = userValue else {
                completion(nil)
                
                return
            }
            
            completion(userValueToUser(userIdentifier: userIdentifier, userValue: userValue))
        }
    }
    
    static func fetchUserWithUpdateTime(
        userIdentifier: String,
        latestUpdateTime: TimeInterval,
        completion: @escaping (UserInfo?) -> Void
    ) {
        databaseReference
            .child(Tables.users)
            .child(userIdentifier)
            .queryOrdered(byChild: Timestamp.key)
            .queryStarting(atValue: latestUpdateTime)
            .observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let userValue = FirebaseDatabaseCoding.fromDictionary(value, type: UsersValue.self)
            else {
                completion(nil)

                return
            }

            completion(userValueToUser(userIdentifier: userIdentifier, userValue: userValue))
        }
    }
    
    static func fetchUserValue(userIdentifier: String, completion: @escaping (UsersValue?) -> Void) {
        databaseReference.child(Tables.users).child(userIdentifier).observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let userValue = FirebaseDatabaseCoding.fromDictionary(value, type: UsersValue.self)
            else {
                completion(nil)

                return
            }
                            
            completion(userValue)
        }
    }
    
    static func fetchUserStatus(userIdentifier: String, completion: @escaping (Bool?) -> Void) {
        databaseReference.child(Tables.usersStatus).child(userIdentifier).observeSingleEvent(of: .value) { snapshot in
            guard
                let value = snapshot.value as? [String: Any],
                let status = FirebaseDatabaseCoding.fromDictionary(value, type: UsersStatusValue.self)
            else {
                return
            }
                            
            completion(status.isOnline)
        }
    }
}

// MARK: - Helper Methods

private extension FirebaseUserService {
    static func userValueToUser(userIdentifier: String, userValue: UsersValue) -> UserInfo {
        let user = UserInfo(
            identifier: userIdentifier,
            firstName: userValue.firstName,
            lastName: userValue.lastName,
            email: userValue.email,
            profileImageURL: userValue.profilePhotoURL)
        
        return user
    }
    
    static func userToUserValue(_ user: UserInfo) -> UsersValue {
        let userValue = UsersValue(
            firstName: user.firstName,
            lastName: user.lastName,
            userName: nil,
            email: user.email,
            profilePhotoURL: user.profileImageURL,
            timestamp: Timestamp.current)
        
        return userValue
    }
}
