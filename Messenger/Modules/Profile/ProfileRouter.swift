//
//  ProfileRouter.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

protocol IProfileRouter: AnyObject {
    func closeProfileViewController()
}

final class ProfileRouter {
    // MARK: Properties
    
    private weak var viewController: ProfileViewController?
    
    // MARK: Initialization
    
    init(viewController: ProfileViewController) {
        self.viewController = viewController
    }
}

// MARK: - IProfileRouter

extension ProfileRouter: IProfileRouter {
    func closeProfileViewController() {
        viewController?.dismiss(animated: true)
    }
}
