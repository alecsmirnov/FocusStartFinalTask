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
    
    private let firebaseRegistrationManager = FirebaseDatabaseRegistrationManager()
}

// MARK: - IRegistrationInteractor

extension RegistrationInteractor: IRegistrationInteractor {
    func signUpAndSignIn(withUser user: RegistrationInfo) {
        firebaseRegistrationManager.signUpAndSignIn(withUser: user) {

        } signUpFailCompletion: { [weak self] in
            self?.presenter?.signUpFail()
        } signInSuccessCompletion: { [weak self] in
            self?.presenter?.signInSuccess()
        } signInFailCompletion: {}
    }
}
