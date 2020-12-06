//
//  RegistrationRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol IRegistrationRouter: AnyObject {
    func closeRegistrationViewController()
    func openChatsViewController(withEmail email: String)
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
        viewController?.dismiss(animated: true)
    }
    
    func openChatsViewController(withEmail email: String) {
        let chatsViewController = ChatsAssembly.createChatsViewController(withEmail: email)
        
        viewController?.navigationController?.pushViewController(chatsViewController, animated: true)
    }
}
