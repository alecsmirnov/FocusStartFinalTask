//
//  LoginPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol ILoginPresenter: AnyObject {
    func viewDidLoad(view: ILoginView)
}

final class LoginPresenter {
    weak var viewController: ILoginViewController?
    var interactor: ILoginInteractor?
    var router: ILoginRouter?
    
    private enum Constants {
        static let passwordLengthMin = 6
    }
}

// MARK: - ILoginPresenter

extension LoginPresenter: ILoginPresenter {
    func viewDidLoad(view: ILoginView) {
        setupViewActions(view: view)
    }
}

// MARK: - Private Methods

private extension LoginPresenter {
    func setupViewActions(view: ILoginView) {
        view.signInButtonAction = { [weak self] in
            self?.signInButtonAction(view: view)
        }
        
        view.signUpButtonAction = { [weak self] in
            self?.signUpButtonAction()
        }
    }
}

// MARK: - View Actions

private extension LoginPresenter {
    func signInButtonAction(view: ILoginView) {
        guard let email = view.emailText,       !email.isEmpty,
              let password = view.passwordText, !password.isEmpty else {
            LoggingService.log(category: .login, layer: .view, type: .alert, with: "empty login fields")
            
            viewController?.showAlert(title: "Required fields are empty", message: "Please enter Email and Password")
            
            return
        }
        
        validateEmail(email)
        validatePassword(password)

        interactor?.signIn(withEmail: email, password: password)
    }
    
    func signUpButtonAction() {
        router?.openRegistrationViewController()
    }
}

// MARK: - Validation

private extension LoginPresenter {
    func validateEmail(_ email: String) {
        guard EmailValidation.isValid(email) else {
            LoggingService.log(category: .login, layer: .presenter, type: .alert, with: "invalid email address")
            
            viewController?.showAlert(title: "Invalid email address", message: "Please try again")
            
            return
        }
        
        FirebaseDatabaseService.isUserExist(withEmail: email) { isExist in
            if !isExist {
                LoggingService.log(category: .login, layer: .presenter, type: .alert, with: "user does not exist")
                
                self.viewController?.showAlert(title: "User does not exist",
                                               message: "Please register or try another address")
            }
            
            return
        }
    }
    
    func validatePassword(_ password: String) {
        guard Constants.passwordLengthMin <= password.count else {
            LoggingService.log(category: .login, layer: .presenter, type: .alert, with: "short password")
            
            viewController?.showAlert(title: "Password is too short",
                                      message: "Minimum length: \(Constants.passwordLengthMin). Please try again")
            
            return
        }
    }
}

// MARK: - ILoginInteractorOutput

extension LoginPresenter: ILoginInteractorOutput {
    func signInSuccess(_ success: Bool, withEmail email: String, password: String) {
        if success {            
            router?.openChatsViewController(withEmail: email)
        }
    }
}
