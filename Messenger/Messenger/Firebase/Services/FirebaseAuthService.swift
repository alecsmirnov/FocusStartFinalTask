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
    typealias AuthUserExistCompletion = (Bool) -> Void
    
    // MARK: Properties
    
    enum AuthError: Error {
        case userNotFound
        case wrongPassword
        case emailAlreadyInUse
        case tooManyRequests
        case undefined
    }
    
    private static let authReference = FirebaseAuth.Auth.auth()
}

// MARK: - Public Methods

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
                    case AuthErrorCode.userNotFound.rawValue:    completion?(nil, AuthError.userNotFound)
                    case AuthErrorCode.wrongPassword.rawValue:   completion?(nil, AuthError.wrongPassword)
                    case AuthErrorCode.tooManyRequests.rawValue: completion?(nil, AuthError.tooManyRequests)
                    default:                                     completion?(nil, AuthError.undefined)
                    }
                }
                
                return
            }
            
            completion?(authResult, nil)
        }
    }
    
    static func signOut() {
        try? authReference.signOut()
        
        sendSignOutNotification()
    }
    
    static func isUserSignedIn() -> Bool {
        return authReference.currentUser != nil
    }
    
    static func isUserExist(withEmail email: String, completion: @escaping AuthUserExistCompletion) {
        authReference.fetchSignInMethods(forEmail: email) { providers, error in
            guard providers == nil, error == nil else {
                completion(false)
                
                return
            }
            
            completion(true)
        }
    }
    
    static func currentUser() -> User? {
        return authReference.currentUser
    }
    
    static func updateCurrentUserEmail(to email: String, password: String, completion: @escaping (AuthError?) -> Void) {
        guard let currentEmail = currentUser()?.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: password)
        
        currentUser()?.reauthenticate(with: credential) { authResult, error in
            guard error == nil else {
                completion(.wrongPassword)
                
                return
            }
            
            currentUser()?.updateEmail(to: email) { error in
                guard error == nil else {
                    completion(.emailAlreadyInUse)
                    
                    return
                }
                
                completion(nil)
            }
        }
    }
}

// MARK: - Private Methods

private extension FirebaseAuthService {
    static func sendSignOutNotification() {
        NotificationCenter.default.post(name: .SignOut, object: nil)
    }
}
