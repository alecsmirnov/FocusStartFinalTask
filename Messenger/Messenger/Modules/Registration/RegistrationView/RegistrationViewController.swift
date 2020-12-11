//
//  RegistrationViewController.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IRegistrationViewController: AnyObject {
    func showEmptyFieldsAlert()
    func showInvalidEmailAlert()
    func showUserAlreadyExistAlert()
    func showShortPasswordAlert(passwordLength: Int)
    
    func showSpinnerView()
    func hideSpinnerView()
}

final class RegistrationViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IRegistrationPresenter?
    
    private var registrationView: IRegistrationView {
        guard let view = view as? RegistrationView else {
            fatalError("view is not a RegistrationView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = RegistrationView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewActions()
    }
}

// MARK: - IRegistrationViewController

extension RegistrationViewController: IRegistrationViewController {
    func showEmptyFieldsAlert() {
        showAlert(title: "Required fields are empty", message: "Please enter First name, Email and Password")
    }
    
    func showInvalidEmailAlert() {
        showAlert(title: "Invalid email address", message: "Please try again")
    }
    
    func showUserAlreadyExistAlert() {
        showAlert(title: "User with this email exists", message: "Please login or try another address")
    }
    
    func showShortPasswordAlert(passwordLength: Int) {
        showAlert(title: "Password is too short", message: "Minimum length: \(passwordLength). Please try again")
    }
    
    func showSpinnerView() {
        registrationView.showSpinnerView()
    }
    
    func hideSpinnerView() {
        registrationView.hideSpinnerView()
    }
}

// MARK: - Private Methods

private extension RegistrationViewController {
    func setupViewActions() {
        registrationView.signUpButtonAction = { [weak self] in
            self?.presenter?.didPressSignUpButton(firstName: self?.registrationView.firstNameText,
                                                  lastName: self?.registrationView.lastNameText,
                                                  email: self?.registrationView.emailText,
                                                  password: self?.registrationView.passwordText)
        }
        
        registrationView.signInButtonAction = { [weak self] in
            self?.presenter?.didPressSignInButton()
        }
    }
    
    func showAlert(title: String, message: String?) {
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertAction.setValue(LoginRegistrationColors.alertActionButton, forKey: "titleTextColor")

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)

        present(alert, animated: true)
    }
}
