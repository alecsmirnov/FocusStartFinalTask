//
//  RegistrationRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IRegistrationRouter: AnyObject {
    func closeRegistrationViewController()
    func openLaunchViewController()
}

final class RegistrationRouter {
    // MARK: Properties
    
    private weak var viewController: RegistrationViewController?
    
    // MARK: Initialization
    
    init(viewController: RegistrationViewController) {
        self.viewController = viewController
    }
}

// MARK: - IRegistrationRouter

extension RegistrationRouter: IRegistrationRouter {
    func closeRegistrationViewController() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func openLaunchViewController() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
