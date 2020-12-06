//
//  RegistrationViewController.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IRegistrationViewController: AnyObject {
    var activityIndicator: Bool { get set }
    
    func showAlert(title: String, message: String?)
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
        
        presenter?.viewDidLoad(view: registrationView)
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

// MARK: - IRegistrationViewController

extension RegistrationViewController: IRegistrationViewController {
    var activityIndicator: Bool {
        get { registrationView.activityIndicator }
        set { registrationView.activityIndicator = newValue }
    }
    
    func showAlert(title: String, message: String?) {
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertAction.setValue(Colors.alertActionButton, forKey: "titleTextColor")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(alertAction)
        
        self.present(alert, animated: true)
    }
}

// MARK: - Appearance

private extension RegistrationViewController {
    func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
