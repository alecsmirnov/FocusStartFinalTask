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

// MARK: - Public Methods

extension FirebaseDatabaseRegistrationManager {
    func signUpAndSignIn(withUser user: RegistrationInfo,
                         signUpSuccessCompletion: (() -> Void)?,
                         signUpFailCompletion: (() -> Void)?,
                         signInSuccessCompletion: (() -> Void)?,
                         signInFailCompletion: (() -> Void)?) {
        signUp(withEmail: user.email, password: user.password) { [weak self] userIdentifier in
            guard let userIdentifier = userIdentifier else {
                signUpFailCompletion?()
                
                return
            }
            
            signUpSuccessCompletion?()
            
            self?.signIn(withEmail: user.email, password: user.password) { success in
                guard success else {
                    signInFailCompletion?()
                    
                    return
                }
                
                signInSuccessCompletion?()
                
                let userValue = UsersValue(firstName: user.firstName,
                                           lastName: user.lastName,
                                           userName: nil,
                                           email: user.email,
                                           profilePhotoURL: nil,
                                           timestamp: Date().timeIntervalSince1970)
                
                self?.addUser(userValue, identifier: userIdentifier)
            }
        }
    }
}

// MARK: - Private Methods

extension FirebaseDatabaseRegistrationManager {
    func signUp(withEmail email: String, password: String, completion: @escaping (String?) -> Void) {
        FirebaseAuthService.createUser(withEmail: email,
                                       password: password) { authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .registration, layer: .interactor, type: .error, with: "\(error)")
                    
                    if error == .emailAlreadyInUse {
                        completion(nil)
                    }
                }
                
                return
            }
            
            LoggingService.log(category: .login,
                               layer: .interactor,
                               type: .info,
                               with: "user \(authResult.user.uid) is logged in")
            
            completion(authResult.user.uid)
        }
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (Bool) -> Void) {
        FirebaseAuthService.signIn(withEmail: email, password: password) { authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .login, layer: .interactor, type: .error, with: "\(error)")
                }
                
                completion(false)
                
                return
            }
            
            LoggingService.log(category: .login,
                               layer: .interactor,
                               type: .info,
                               with: "user \(authResult.user.uid) is signed in")
            
            completion(true)
        }
    }
    
    func addUser(_ user: UsersValue, identifier: String) {
        if let userRecord = FirebaseDatabaseCoding.toDictionary(user) {
            databaseReference.child(Tables.users)
                             .child(identifier)
                             .setValue(userRecord)
            
            FirebaseDatabaseUserStatusService.setUserStatus(userIdentifier: identifier, isOnline: true)
            
            LoggingService.log(category: .registration,
                               layer: .interactor,
                               type: .info,
                               with: "create firebase user \(identifier)")
        }
    }
}
