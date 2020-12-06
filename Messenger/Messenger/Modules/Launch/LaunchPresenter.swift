//
//  LaunchPresenter.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

protocol ILaunchPresenter: AnyObject {
    func viewDidAppear()
}

final class LaunchPresenter {
    weak var viewController: ILaunchViewController?
    var interactor: ILaunchInteractor?
    var router: ILaunchRouter?
}

// MARK: - ILaunchPresenter

extension LaunchPresenter: ILaunchPresenter {
    func viewDidAppear() {
        guard let isUserSignedIn = interactor?.isUserSignedIn else {
            LoggingService.log(category: .launch, layer: .presenter, type: .error, with: "interactor is not attached")
            
            return
        }
        
        if isUserSignedIn {
            router?.openChatsViewController()
        } else {
            router?.openLoginViewController()
        }
    }
}
