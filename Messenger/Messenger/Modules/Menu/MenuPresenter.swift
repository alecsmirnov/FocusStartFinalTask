//
//  MenuPresenter.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import Dispatch

protocol IMenuPresenter: AnyObject {
    func viewDidLoad()
    
    func didSelectMenu(with option: MenuView.MenuOptions)
}

final class MenuPresenter {
    weak var viewController: IMenuViewController?
    var interactor: IMenuInteractor?
    var router: IMenuRouter?
    
    private var user: UserInfo?
}

// MARK: - IMenuPresenter

extension MenuPresenter: IMenuPresenter {
    func viewDidLoad() {
        viewController?.hideMenu()
        interactor?.fetchUser()
    }
    
    func didSelectMenu(with option: MenuView.MenuOptions) {        
        switch option {
        case .editProfile:
            router?.openProfileViewController(with: user)
        case .signOut:
            interactor?.signOut()
            router?.openLaunchViewController()
        }
    }
}

// MARK: - IMenuInteractorOutput

extension MenuPresenter: IMenuInteractorOutput {
    func fetchUserSuccess(_ user: UserInfo) {
        self.user = user
        
        DispatchQueue.main.async {
            self.viewController?.showMenu()
            self.viewController?.setUserInfo(user)
        }
    }
}
