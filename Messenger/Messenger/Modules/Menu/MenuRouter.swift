//
//  MenuRouter.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

protocol IMenuRouter: AnyObject {
    func openLaunchViewController()
}

final class MenuRouter {
    // MARK: Properties
    
    private weak var viewController: MenuViewController?
    
    // MARK: Initialization
    
    init(viewController: MenuViewController) {
        self.viewController = viewController
    }
}

// MARK: - IMenuRouter

extension MenuRouter: IMenuRouter {
    func openLaunchViewController() {
        let navigationController = viewController?.navigationController
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        navigationController?.popToRootViewController(animated: true)
    }
}
