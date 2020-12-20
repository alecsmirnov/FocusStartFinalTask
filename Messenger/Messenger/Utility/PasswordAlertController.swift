//
//  PasswordAlertController.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import UIKit

protocol PasswordAlertControllerDelegate: AnyObject {
    func passwordAlertController(_ passwordAlertController: PasswordAlertController, didPressSubmitWith text: String?)
    func passwordAlertControllerDidPressDismiss(_ passwordAlertController: PasswordAlertController)
}

final class PasswordAlertController: NSObject {
    // MARK: Properties
    
    private weak var presentationController: UIViewController?
    private weak var delegate: PasswordAlertControllerDelegate?
    
    private lazy var alertController: UIAlertController = {
        let alertController = UIAlertController(title: "Security",
                                                message: "Please enter password",
                                                preferredStyle: .alert)
        
        alertController.addTextField()
        alertController.textFields?.first?.isSecureTextEntry = true

        let submitAlertAction = UIAlertAction(title: "Submit", style: .default) { [weak alertController] _ in
            if let password = alertController?.textFields?.first?.text {
                alertController?.textFields?.first?.text = nil
                
                self.delegate?.passwordAlertController(self, didPressSubmitWith: password)
            }
        }
        
        let dismissAlertAction = UIAlertAction(title: "Dismiss", style: .default) { _ in
            self.delegate?.passwordAlertControllerDidPressDismiss(self)
        }
        
        submitAlertAction.setValue(Colors.themeColor, forKey: "titleTextColor")
        dismissAlertAction.setValue(LoginRegistrationColors.alertActionButton, forKey: "titleTextColor")
        
        alertController.addAction(submitAlertAction)
        alertController.addAction(dismissAlertAction)
        
        return alertController
    }()
    
    // MARK: Initialization
    
    init(presentationController: UIViewController, delegate: PasswordAlertControllerDelegate) {
        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    }
}

extension PasswordAlertController {
    func showAlert() {
        presentationController?.present(alertController, animated: true)
    }
}
