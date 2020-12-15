//
//  FirebaseDatabaseSearchManager.swift
//  Messenger
//
//  Created by Admin on 15.12.2020.
//

import FirebaseDatabase

final class FirebaseDatabaseSearchManager {
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

extension FirebaseDatabaseSearchManager {
    func fetchUsers(completion: @escaping ([UserInfo]?) -> Void) {
        databaseReference.child(Tables.users)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
            
            let usersValues = FirebaseDatabaseService.dictionaryToDecodable(value, type: [String: UsersValue].self)
            completion(FirebaseDatabaseSearchManager.usersValuesToUsers(usersValues))
        }
    }
    
    func fetchUsers(by parameter: String, key: SearchKey, completion: @escaping ([UserInfo]?) -> Void) {
        let queryableParameter = parameter.lowercased()
        
        databaseReference.child(Tables.users)
                         .queryOrdered(byChild: key.rawValue)
                         .queryStarting(atValue: queryableParameter)
                         .queryEnding(atValue: queryableParameter + Constants.anyCharacterValue)
                         .observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                completion(nil)
                
                return
            }
                
            let usersValues = FirebaseDatabaseService.dictionaryToDecodable(value, type: [String: UsersValue].self)
            completion(FirebaseDatabaseSearchManager.usersValuesToUsers(usersValues))
        }
    }
}

// MARK: - Helper Methods

private extension FirebaseDatabaseSearchManager {
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
