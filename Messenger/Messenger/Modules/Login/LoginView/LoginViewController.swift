//
//  LoginViewController.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

protocol ILoginViewController: AnyObject {
    func showSpinnerView()
    func hideSpinnerView()
    
    func showEmptyFieldsAlert()
    func showInvalidEmailAlert()
    func showUserNotExistAlert()
    func showWrongPasswordAlert()
}

final class LoginViewController: UIViewController {
    // MARK: Properties
    
    var presenter: ILoginPresenter?
    
    private var simpleAlertController: SimpleAlertController?
    
    private var loginView: LoginView {
        guard let view = view as? LoginView else {
            fatalError("view is not a LoginView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = LoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
}

// MARK: - ILoginViewController

extension LoginViewController: ILoginViewController {
    func showSpinnerView() {
        loginView.showSpinnerView()
    }
    
    func hideSpinnerView() {
        loginView.hideSpinnerView()
    }
    
    func showEmptyFieldsAlert() {
        simpleAlertController?.showAlert(title: "Required fields are empty", message: "Please enter Email and Password")
    }
    
    func showInvalidEmailAlert() {
        simpleAlertController?.showAlert(title: "Invalid email address", message: "Please try again")
    }
    
    func showUserNotExistAlert() {
        simpleAlertController?.showAlert(title: "User does not exist",
                                         message: "Please register or try another address")
    }
    
    func showWrongPasswordAlert() {
        simpleAlertController?.showAlert(title: "Wrong password", message: "Please try again")
    }
}

// MARK: - Private Methods

private extension LoginViewController {
    func setupView() {
        loginView.delegate = self
        
        setupSimpleAlertController()
    }
    
    func setupSimpleAlertController() {
        simpleAlertController = SimpleAlertController(presentationController: self)
    }
}

// MARK: - LoginViewDelegate

extension LoginViewController: LoginViewDelegate {
    func loginViewSignIn(_ loginView: LoginView) {
        presenter?.didPressSignInButton(email: loginView.emailText, password: loginView.passwordText)
    }
    
    func loginViewSignUp(_ loginView: LoginView) {
        presenter?.didPressSignUpButton()
    }
}
