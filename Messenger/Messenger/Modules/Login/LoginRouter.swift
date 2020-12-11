//
//  LoginRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol ILoginRouter: AnyObject {
    func openRegistrationViewController()
    func openLaunchViewController()
}

final class LoginRouter {
    // MARK: Properties
    
    private weak var viewController: LoginViewController?
    
    // MARK: Initialization
    
    init(viewController: LoginViewController) {
        self.viewController = viewController
    }
}

// MARK: - ILoginRouter

extension LoginRouter: ILoginRouter {    
    func openRegistrationViewController() {
        let registrationViewController = RegistrationAssembly.createRegistrationViewController()
        
        viewController?.navigationController?.pushViewController(registrationViewController, animated: true)
    }
    
    func openLaunchViewController() {
        viewController?.navigationController?.popToRootViewController(animated: true)
    }
}
