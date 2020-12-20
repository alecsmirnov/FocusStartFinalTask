//
//  SimpleAlertController.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import UIKit

protocol SimpleAlertControllerDelegate: AnyObject {
    func simpleAlertControllerDidPressDismiss(_ simpleAlertController: SimpleAlertController)
}

final class SimpleAlertController: NSObject {
    // MARK: Properties
    
    private weak var presentationController: UIViewController?
    private weak var delegate: PasswordAlertControllerDelegate?
    
    private lazy var alertController: UIAlertController = {
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertAction.setValue(LoginRegistrationColors.alertActionButton, forKey: "titleTextColor")

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.addAction(alertAction)
        
        return alertController
    }()
    
    // MARK: Initialization
    
    init(presentationController: UIViewController, delegate: PasswordAlertControllerDelegate) {
        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    }
}

extension SimpleAlertController {
    func showAlert(title: String?, message: String?) {
        alertController.title = title
        alertController.message = message
        
        presentationController?.present(alertController, animated: true)
    }
}
