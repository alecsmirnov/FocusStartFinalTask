//
//  MenuPresenter.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import Foundation

protocol IMenuPresenter: AnyObject {
    func viewDidLoad(view: IMenuView)
    
    func didSelectImage(with data: Data)
}

final class MenuPresenter {
    weak var viewController: IMenuViewController?
    var interactor: IMenuInteractor?
    var router: IMenuRouter?
}

// MARK: - IMenuPresenter

extension MenuPresenter: IMenuPresenter {
    func viewDidLoad(view: IMenuView) {
        view.profilePhotoTapAction = { [weak self] in
            self?.viewController?.takePhoto()
        }
        
        view.signOutButtonAction = { [weak self] in
            self?.interactor?.signOut()
            self?.router?.openLaunchViewController()
        }
    }
    
    func didSelectImage(with data: Data) {
        interactor?.uploadProfileImageData(data)
    }
}

// MARK: - IMenuInteractorOutput

extension MenuPresenter: IMenuInteractorOutput {}
