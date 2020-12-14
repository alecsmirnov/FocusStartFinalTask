//
//  RegistrationInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import Foundation

protocol IRegistrationInteractor: AnyObject {    
    func signUpAndSignIn(withUser user: RegistrationInfo)
}

protocol IRegistrationInteractorOutput: AnyObject {
    func signInSuccess()
    
    func signUpFail()
}

final class RegistrationInteractor {
    weak var presenter: IRegistrationInteractorOutput?
}

// MARK: - IRegistrationInteractor

extension RegistrationInteractor: IRegistrationInteractor {
    func signUpAndSignIn(withUser user: RegistrationInfo) {
        FirebaseAuthService.createUser(withEmail: user.email,
                                       password: user.password) { [weak self] authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .registration, layer: .interactor, type: .error, with: "\(error)")
                    
                    if error == .emailAlreadyInUse {
                        self?.presenter?.signUpFail()
                    }
                }
                
                return
            }
            
            LoggingService.log(category: .registration,
                               layer: .interactor,
                               type: .info,
                               with: "create firebase user \(authResult.user.uid)")
            
            let firebaseUser = UsersValue(firstName: user.firstName,
                                          lastName: user.lastName,
                                          userName: nil,
                                          email: user.email,
                                          profilePhotoURL: nil, timestamp: Date().timeIntervalSince1970)
            
            // TODO: Add user after signIn
            
            FirebaseDatabaseService.addUser(firebaseUser, identifier: authResult.user.uid)
            
            self?.signIn(withEmail: user.email, password: user.password)
        }
    }
}

// MARK: - Private Methods

private extension RegistrationInteractor {
    func signIn(withEmail email: String, password: String) {
        FirebaseAuthService.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .login, layer: .interactor, type: .error, with: "\(error)")
                }
                
                return
            }
            
            LoggingService.log(category: .login,
                               layer: .interactor,
                               type: .info,
                               with: "user \(authResult.user.uid) is logged in")
            
            self?.presenter?.signInSuccess()
        }
    }
}
