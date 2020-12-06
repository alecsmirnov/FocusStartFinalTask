//
//  RegistrationPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IRegistrationPresenter: AnyObject {
    func viewDidLoad(view: IRegistrationView)
}

final class RegistrationPresenter {
    weak var viewController: IRegistrationViewController?
    var interactor: IRegistrationInteractor?
    var router: IRegistrationRouter?
    
    private enum Constants {
        static let passwordLengthMin = 6
    }
}

// MARK: - IRegistrationPresenter

extension RegistrationPresenter: IRegistrationPresenter {
    func viewDidLoad(view: IRegistrationView) {
        setupViewActions(view: view)
    }
}

// MARK: - Private Methods

private extension RegistrationPresenter {
    func setupViewActions(view: IRegistrationView) {
        view.signUpButtonAction = { [weak self] in
            self?.signUpButtonAction(view: view)
        }
        
        view.signInButtonAction = { [weak self] in
            self?.signInButtonAction()
        }
    }
}

// MARK: - View Actions

private extension RegistrationPresenter {
    func signUpButtonAction(view: IRegistrationView) {
        guard let firstName = view.firstNameText, !firstName.isEmpty,
              let lastName = view.lastNameText,
              let email = view.emailText,         !email.isEmpty,
              let password = view.passwordText,   !password.isEmpty else {
            LoggingService.log(category: .registration, layer: .view, type: .alert, with: "empty registration fields")
            
            viewController?.showAlert(title: "Required fields are empty",
                                      message: "Please enter First name, Email and Password")
            
            return
        }
        
        validateEmail(email)
        validatePassword(password)
        
        let user = RegistrationData(firstName: firstName, lastName: lastName, email: email, password: password)
        
        viewController?.activityIndicator = true
        interactor?.signUp(withUser: user)
    }
    
    func signInButtonAction() {
        router?.closeRegistrationViewController()
    }
}

// MARK: - Validation

private extension RegistrationPresenter {
    func validateEmail(_ email: String) {
        guard EmailValidation.isValid(email) else {
            LoggingService.log(category: .registration, layer: .presenter, type: .alert, with: "invalid email address")
            
            viewController?.showAlert(title: "Invalid email address", message: "Please try again")
            
            return
        }
        
        FirebaseDatabaseService.isUserExist(withEmail: email) { isExist in
            if isExist {
                LoggingService.log(category: .registration, layer: .presenter, type: .alert, with: "user already exist")
                
                self.viewController?.showAlert(title: "User with this email exists",
                                               message: "Please login or try another address")
            }
            
            return
        }
    }
    
    func validatePassword(_ password: String) {
        guard Constants.passwordLengthMin <= password.count else {
            LoggingService.log(category: .registration, layer: .presenter, type: .alert, with: "short password")
            
            viewController?.showAlert(title: "Password is too short",
                                      message: "Minimum length: \(Constants.passwordLengthMin). Please try again")
            
            return
        }
    }
}

// MARK: - IRegistrationInteractorOutput

extension RegistrationPresenter: IRegistrationInteractorOutput {
    func signUpSuccess(_ success: Bool, withUser user: RegistrationData) {
        viewController?.activityIndicator = false
        
        if success {
            router?.openChatsViewController(withEmail: user.email)
        }
    }
}
