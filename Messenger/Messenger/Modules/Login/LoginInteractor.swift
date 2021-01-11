//
//  LoginInteractor.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol ILoginInteractor: AnyObject {
    func signIn(withEmail email: String, password: String)
}

protocol ILoginInteractorOutput: AnyObject {
    func signInSuccess()
    func signInFail(_ error: ILoginInteractorError)
}

enum ILoginInteractorError {
    case userNotFound
    case wrongPassword
}

final class LoginInteractor {
    weak var presenter: ILoginInteractorOutput?
}

// MARK: - ILoginInteractor

extension LoginInteractor: ILoginInteractor {
    func signIn(withEmail email: String, password: String) {
        FirebaseAuthService.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    switch error {
                    case .userNotFound: self?.presenter?.signInFail(.userNotFound)
                    case .wrongPassword: self?.presenter?.signInFail(.wrongPassword)
                    default: break
                    }
                    
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
