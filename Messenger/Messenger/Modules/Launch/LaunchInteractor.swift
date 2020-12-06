//
//  LaunchInteractor.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

protocol ILaunchInteractor: AnyObject {
    var isUserSignedIn: Bool { get }
}

final class LaunchInteractor {}

// MARK: - ILaunchInteractor

extension LaunchInteractor: ILaunchInteractor {
    var isUserSignedIn: Bool {
        return FirebaseAuthService.isUserSignedIn()
    }
}
