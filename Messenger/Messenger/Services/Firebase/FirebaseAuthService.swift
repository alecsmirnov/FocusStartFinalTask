//
//  FirebaseAuthService.swift
//  Messenger
//
//  Created by Admin on 23.11.2020.
//

import FirebaseAuth

enum FirebaseAuthService {
    // MARK: Completions
    
    typealias AuthDataResultCompletion = (AuthDataResult?, AuthError?) -> Void
    
    // MARK: Properties
    
    enum AuthError: Error {
        case userNotFound
        case wrongPassword
        case emailAlreadyInUse
        case undefined
    }
    
    static private let authReference = FirebaseAuth.Auth.auth()
}

// MARK: - Methods

extension FirebaseAuthService {
    static func createUser(withEmail email: String, password: String, completion: AuthDataResultCompletion?) {
        authReference.createUser(withEmail: email, password: password) { authResult, error in
            guard authResult != nil else {
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue: completion?(nil, AuthError.emailAlreadyInUse)
                    default:                                       completion?(nil, AuthError.undefined)
                    }
                }
                
                return
            }
            
            completion?(authResult, nil)
        }
    }
    
    static func signIn(withEmail email: String, password: String, completion: AuthDataResultCompletion?) {
        authReference.signIn(withEmail: email, password: password) { authResult, error in
            guard authResult != nil else {
                if let error = error as NSError? {
                    switch error.code {
                    case AuthErrorCode.userNotFound.rawValue:  completion?(nil, AuthError.userNotFound)
                    case AuthErrorCode.wrongPassword.rawValue: completion?(nil, AuthError.wrongPassword)
                    default:                                   completion?(nil, AuthError.undefined)
                    }
                }
                
                return
            }
            
            completion?(authResult, nil)
        }
    }
    
    static func signOut() {
        try? authReference.signOut()
    }
    
    static func isUserSignedIn() -> Bool {
        return authReference.currentUser != nil
    }
    
    static func currentUser() -> User? {
        return authReference.currentUser
    }
}
