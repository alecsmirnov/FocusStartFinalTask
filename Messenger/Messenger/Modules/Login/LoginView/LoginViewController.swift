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
    
    private var loginView: ILoginView {
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
        
        setupViewActions()
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
        showAlert(title: "Required fields are empty", message: "Please enter Email and Password")
    }
    
    func showInvalidEmailAlert() {
        showAlert(title: "Invalid email address", message: "Please try again")
    }
    
    func showUserNotExistAlert() {
        showAlert(title: "User does not exist", message: "Please register or try another address")
    }
    
    func showWrongPasswordAlert() {
        showAlert(title: "Wrong password", message: "Please try again")
    }
}

// MARK: - Private Methods

private extension LoginViewController {
    func setupViewActions() {
        loginView.signInButtonAction = { [weak self] in
            self?.presenter?.didPressSignInButton(email: self?.loginView.emailText,
                                                  password: self?.loginView.passwordText)
        }
        
        loginView.signUpButtonAction = { [weak self] in
            self?.presenter?.didPressSignUpButton()
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
