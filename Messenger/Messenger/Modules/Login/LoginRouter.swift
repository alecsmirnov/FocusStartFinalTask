//
//  LoginRouter.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

protocol ILoginRouter: AnyObject {
    func openRegistrationViewController()
    func openChatsViewController(withEmail email: String)
}

final class LoginRouter {
    // MARK: Properties
    
    private enum AnimationDurations {
        static let present = 0.6
        static let dismiss = 0.6
    }
    
    private weak var viewController: LoginViewController?
    
    private var transitionDelegate = TransitionDelegate(
        presentAnimationController: ZoomAnimationController(duration: AnimationDurations.present,
                                                            animationType: .present),
        dismissAnimationController: ZoomAnimationController(duration: AnimationDurations.dismiss,
                                                            animationType: .dismiss)
    )
    
    // MARK: Initialization
    
    init(viewController: LoginViewController) {
        self.viewController = viewController
    }
}

// MARK: - ILoginRouter

extension LoginRouter: ILoginRouter {    
    func openRegistrationViewController() {
        let registrationViewController = RegistrationAssembly.createRegistrationViewController()
        
        registrationViewController.modalPresentationStyle = .custom
        registrationViewController.transitioningDelegate = transitionDelegate
        
        viewController?.present(registrationViewController, animated: true)
    }
    
    func openChatsViewController(withEmail email: String) {
        let chatsViewController = ChatsAssembly.createChatsViewController(withEmail: email)
        
        viewController?.navigationController?.pushViewController(chatsViewController, animated: true)
    }
}
