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
        signUp(withEmail: user.email, password: user.password) { userIdentifier in
            guard let userIdentifier = userIdentifier else {
                self.presenter?.signUpFail()
                
                return
            }
            
            self.signIn(withEmail: user.email, password: user.password) { success in
                guard success else { return }
                
                self.presenter?.signInSuccess()
                
                let userValue = UsersValue(firstName: user.firstName,
                                           lastName: user.lastName,
                                           userName: nil,
                                           email: user.email,
                                           profilePhotoURL: nil,
                                           timestamp: Timestamp.current)
                
                FirebaseUserService.addUser(userValue, identifier: userIdentifier)
                
                LoggingService.log(category: .registration,
                                   layer: .interactor,
                                   type: .info,
                                   with: "create firebase user \(userIdentifier)")
            }
        }
    }
}

// MARK: - Private Methods

extension RegistrationInteractor {
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
}
