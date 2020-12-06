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
    func signInSuccess(_ success: Bool, withEmail email: String, password: String)
}

final class LoginInteractor {    
    weak var presenter: ILoginInteractorOutput?
}

// MARK: - ILoginInteractor

extension LoginInteractor: ILoginInteractor {
    func signIn(withEmail email: String, password: String) {
        FirebaseAuthService.signIn(withEmail: email, password: password) { authResult, error in
            guard let authResult = authResult else {
                if let error = error {
                    LoggingService.log(category: .login, layer: .interactor, type: .error, with: "\(error)")
                }
                
                self.presenter?.signInSuccess(false, withEmail: email, password: password)
                
                return
            }
            
            LoggingService.log(category: .login,
                               layer: .interactor,
                               type: .info,
                               with: "user \(authResult.user) is logged in")
            
            self.presenter?.signInSuccess(true, withEmail: email, password: password)
        }
    }
}
