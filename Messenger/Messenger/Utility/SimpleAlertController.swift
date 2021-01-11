//
//  SimpleAlertController.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import UIKit

final class SimpleAlertController: NSObject {
    // MARK: Properties
    
    private weak var presentationController: UIViewController?
    
    private lazy var alertController: UIAlertController = {
        let alertAction = UIAlertAction(title: "Dismiss", style: .cancel)
        alertAction.setValue(LoginRegistrationColors.alertActionButton, forKey: "titleTextColor")

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.addAction(alertAction)
        
        return alertController
    }()
    
    // MARK: Initialization
    
    init(presentationController: UIViewController) {
        super.init()

        self.presentationController = presentationController
    }
}

extension SimpleAlertController {
    func showAlert(title: String?, message: String?) {
        alertController.title = title
        alertController.message = message
        
        presentationController?.present(alertController, animated: true)
    }
}
