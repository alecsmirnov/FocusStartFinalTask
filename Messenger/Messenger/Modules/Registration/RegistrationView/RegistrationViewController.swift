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
    
    private var simpleAlertController: SimpleAlertController?
    
    private var registrationView: RegistrationView {
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
        
        setupView()
    }
}

// MARK: - IRegistrationViewController

extension RegistrationViewController: IRegistrationViewController {
    func showEmptyFieldsAlert() {
        simpleAlertController?.showAlert(title: "Required fields are empty",
                                         message: "Please enter First name, Email and Password")
    }
    
    func showInvalidEmailAlert() {
        simpleAlertController?.showAlert(title: "Invalid email address", message: "Please try again")
    }
    
    func showUserAlreadyExistAlert() {
        simpleAlertController?.showAlert(title: "User with this email exists",
                                         message: "Please login or try another address")
    }
    
    func showShortPasswordAlert(passwordLength: Int) {
        simpleAlertController?.showAlert(title: "Password is too short",
                                         message: "Minimum length: \(passwordLength). Please try again")
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
    func setupView() {
        registrationView.delegate = self
        
        setupSimpleAlertController()
    }
    
    func setupSimpleAlertController() {
        simpleAlertController = SimpleAlertController(presentationController: self)
    }
}

// MARK: - Private Methods

extension RegistrationViewController: RegistrationViewDelegate {
    func registrationViewSignUp(_ loginView: RegistrationView) {
        presenter?.didPressSignUpButton(firstName: registrationView.firstNameText,
                                        lastName: registrationView.lastNameText,
                                        email: registrationView.emailText,
                                        password: registrationView.passwordText)
    }
    
    func registrationViewSignIn(_ loginView: RegistrationView) {
        presenter?.didPressSignInButton()
    }
}
