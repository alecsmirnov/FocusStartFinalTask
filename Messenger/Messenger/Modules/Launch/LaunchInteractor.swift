//
//  LaunchInteractor.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import UIKit

protocol ILaunchInteractor: AnyObject {
    var isUserSignedIn: Bool { get }
}

final class LaunchInteractor {
    init() {
        observeAppBecomeActiveNotification()
        observeAppMovedToBackgroundNotification()
        observeAppWillTerminateNotification()
    }
}

// MARK: - ILaunchInteractor

extension LaunchInteractor: ILaunchInteractor {
    var isUserSignedIn: Bool {
        return FirebaseAuthService.isUserSignedIn()
    }
}

// MARK: - Private Methods

extension LaunchInteractor {
    func observeAppBecomeActiveNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    func observeAppMovedToBackgroundNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appMovedToBackground),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    func observeAppWillTerminateNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
    }
}

// MARK: - Actions

extension LaunchInteractor {
    @objc func appBecomeActive() {
        if let userIdentifier = FirebaseAuthService.currentUser()?.uid {
            FirebaseDatabaseUserStatusService.setUserStatus(userIdentifier: userIdentifier, isOnline: true)
        }
    }
    
    @objc func appMovedToBackground() {
        if let userIdentifier = FirebaseAuthService.currentUser()?.uid {
            FirebaseDatabaseUserStatusService.setUserStatus(userIdentifier: userIdentifier, isOnline: false)
        }
    }
    
    @objc func appWillTerminate() {
        appMovedToBackground()
    }
}
