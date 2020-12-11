//
//  LoginPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol ILoginPresenter: AnyObject {
    func didPressSignInButton(email: String?, password: String?)
    func didPressSignUpButton()
}

final class LoginPresenter {
    weak var viewController: ILoginViewController?
    var interactor: ILoginInteractor?
    var router: ILoginRouter?
}

// MARK: - ILoginPresenter

extension LoginPresenter: ILoginPresenter {
    func didPressSignInButton(email: String?, password: String?) {
        guard let email = email,       !email.isEmpty,
              let password = password, !password.isEmpty else {
            LoggingService.log(category: .login, layer: .view, type: .alert, with: "empty login fields")
            
            viewController?.showEmptyFieldsAlert()
            
            return
        }
        
        guard EmailValidation.isValid(email) else {
            LoggingService.log(category: .login, layer: .presenter, type: .alert, with: "invalid email address")
            
            viewController?.showInvalidEmailAlert()
            
            return
        }
        
        FirebaseDatabaseService.isUserExist(withEmail: email) { [weak self] isExist in
            if !isExist {
                LoggingService.log(category: .login, layer: .presenter, type: .alert, with: "user does not exist")
                
                self?.viewController?.showUserNotExistAlert()
            }
            
            return
        }

        interactor?.signIn(withEmail: email, password: password)
        viewController?.showSpinnerView()
    }
    
    func didPressSignUpButton() {
        router?.openRegistrationViewController()
    }
}

// MARK: - ILoginInteractorOutput

extension LoginPresenter: ILoginInteractorOutput {
    func signInSuccess() {
        viewController?.hideSpinnerView()
        router?.openLaunchViewController()
    }
    
    func signInFail() {
        viewController?.hideSpinnerView()
        viewController?.showWrongPasswordAlert()
    }
}
