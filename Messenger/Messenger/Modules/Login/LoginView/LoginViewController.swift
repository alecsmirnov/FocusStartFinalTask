//
//  LoginViewController.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

protocol ILoginViewController: AnyObject {
    func showAlert(title: String, message: String?)
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
        
        presenter?.viewDidLoad(view: loginView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigationBar()
    }
}

// MARK: - ILoginViewController

extension LoginViewController: ILoginViewController {
    func showAlert(title: String, message: String?) {
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertAction.setValue(Colors.alertActionButton, forKey: "titleTextColor")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        
        self.present(alert, animated: true)
    }
}

// MARK: - Appearance

private extension LoginViewController {
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
