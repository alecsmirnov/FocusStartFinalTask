//
//  RegistrationInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IRegistrationInteractor: AnyObject {
    func signUp(withUser user: RegistrationData)
}

protocol IRegistrationInteractorOutput: AnyObject {
    func signUpSuccess(_ success: Bool, withUser user: RegistrationData)
}

final class RegistrationInteractor {
    weak var presenter: IRegistrationInteractorOutput?
}

// MARK: - IRegistrationInteractor

extension RegistrationInteractor: IRegistrationInteractor {
    func signUp(withUser user: RegistrationData) {
        FirebaseAuthService.createUser(withEmail: user.email, password: user.password) { authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .registration, layer: .interactor, type: .error, with: "\(error)")
                }
                
                self.presenter?.signUpSuccess(false, withUser: user)
                
                return
            }
            
            LoggingService.log(category: .registration,
                               layer: .interactor,
                               type: .info,
                               with: "create firebase user \(authResult.user)")
            
            let firebaseUser = FirebaseUser(firstName: user.firstName,
                                            lastName: user.lastName,
                                            userName: nil,
                                            email: user.email,
                                            profilePhotoURL: nil)
            FirebaseDatabaseService.addUser(firebaseUser)

            self.presenter?.signUpSuccess(true, withUser: user)
        }
    }
}
