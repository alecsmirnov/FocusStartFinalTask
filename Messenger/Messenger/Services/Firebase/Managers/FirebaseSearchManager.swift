//
//  FirebaseSearchManager.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//

import FirebaseDatabase

final class FirebaseSearchManager {
    enum SearchKey: String {
        case name = "info/queryable_name"
        case userName = "info/queryable_user_name"
        case email = "info/email"
    }
    
    enum Constants {
        static let anyCharacterValue = "\u{f8ff}"
    }
    
    private let databaseReference = Database.database().reference()
}

extension FirebaseSearchManager {
    func fetchUsers(completion: @escaping ([UserInfo]?) -> Void) {
        databaseReference.child(Tables.users)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let usersValues = FirebaseDatabaseCoding.fromDictionary(value,type: [String: UsersValue].self) else {
                completion(nil)
                
                return
            }
            
            completion(FirebaseSearchManager.usersValuesToUsers(usersValues))
        }
    }
    
    func fetchUsers(by parameter: String, key: SearchKey, completion: @escaping ([UserInfo]?) -> Void) {
        let queryableParameter = parameter.lowercased()
        
        databaseReference.child(Tables.users)
                         .queryOrdered(byChild: key.rawValue)
                         .queryStarting(atValue: queryableParameter)
                         .queryEnding(atValue: queryableParameter + Constants.anyCharacterValue)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let usersValues = FirebaseDatabaseCoding.fromDictionary(value, type: [String: UsersValue].self) else {
                completion(nil)
                
                return
            }
            
            completion(FirebaseSearchManager.usersValuesToUsers(usersValues))
        }
    }
}

// MARK: - Helper Methods

private extension FirebaseSearchManager {
    static func usersValuesToUsers(_ usersValues: [String: UsersValue]) -> [UserInfo] {
        let users = usersValues.map { userIdentifier, userValue in
            return UserInfo(identifier: userIdentifier,
                            firstName: userValue.firstName,
                            lastName: userValue.lastName,
                            email: userValue.email,
                            profileImageData: nil)
        }
        
        return users
    }
}