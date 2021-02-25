//
//  RegistrationPresenter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IRegistrationPresenter: AnyObject {
    func didPressSignUpButton(firstName: String?, lastName: String?, email: String?, password: String?)
    func didPressSignInButton()
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
    func didPressSignUpButton(firstName: String?, lastName: String?, email: String?, password: String?) {
        guard
            let firstName = firstName, !firstName.isEmpty,
            let lastName = lastName,
            let email = email, !email.isEmpty,
            let password = password, !password.isEmpty
        else {
            LoggingService.log(category: .registration, layer: .view, type: .alert, with: "empty registration fields")
            
            viewController?.showEmptyFieldsAlert()
            
            return
        }
        
        validateEmail(email)
        validatePassword(password)
        
        let user = RegistrationInfo(firstName: firstName, lastName: lastName, email: email, password: password)
        
        viewController?.showSpinnerView()
        interactor?.signUpAndSignIn(withUser: user)
    }
    
    func didPressSignInButton() {
        router?.closeRegistrationViewController()
    }
}

// MARK: - Validation

private extension RegistrationPresenter {
    func validateEmail(_ email: String) {
        guard EmailValidation.isValid(email) else {
            LoggingService.log(category: .registration, layer: .presenter, type: .alert, with: "invalid email address")
            
            viewController?.showInvalidEmailAlert()
            
            return
        }
    }
    
    func validatePassword(_ password: String) {
        guard Constants.passwordLengthMin <= password.count else {
            LoggingService.log(category: .registration, layer: .presenter, type: .alert, with: "short password")
            
            viewController?.showShortPasswordAlert(passwordLength: Constants.passwordLengthMin)
            
            return
        }
    }
}

// MARK: - IRegistrationInteractorOutput

extension RegistrationPresenter: IRegistrationInteractorOutput {
    func signInSuccess() {
        viewController?.hideSpinnerView()
        router?.openLaunchViewController()
    }
    
    func signUpFail() {
        viewController?.hideSpinnerView()
        viewController?.showUserAlreadyExistAlert()
    }
}
