//
//  ProfileInteractor.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import Foundation

protocol IProfileInteractor: AnyObject {
    func updateProfile(_ profile: ProfileInfo)
    func updateProfile(_ profile: ProfileInfo, withEmail email: String, password: String)
}

protocol IProfileInteractorOutput: AnyObject {
    func updateProfileSuccess()
    func updateProfileFail()
    func updateProfilePasswordFail()
}

final class ProfileInteractor {
    weak var presenter: IProfileInteractorOutput?
}

// MARK: - IProfileInteractor

extension ProfileInteractor: IProfileInteractor {
    func updateProfile(_ profile: ProfileInfo) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        if let profileImageData = profile.profileImageData {
            FirebaseStorageService.uploadProfileImageData(profileImageData, userIdentifier: userIdentifier) { error in
                guard error == nil else { return }
                
                FirebaseStorageService.downloadProfileImageDataURL(userIdentifier: userIdentifier) { urlString, error in
                    self.updateUser(userIdentifier: userIdentifier,
                                    firstName: profile.firstName,
                                    lastName: profile.lastName,
                                    email: profile.email,
                                    profileImageURL: urlString)
                }
            }
        } else {
            updateUser(userIdentifier: userIdentifier,
                       firstName: profile.firstName,
                       lastName: profile.lastName,
                       email: profile.email,
                       profileImageURL: nil)
        }
    }
    
    func updateProfile(_ profile: ProfileInfo, withEmail email: String, password: String) {
        FirebaseAuthService.updateCurrentUserEmail(to: email, password: password) { [weak self] error in
            guard error == nil else {
                if let error = error {
                    switch error {
                    case .emailAlreadyInUse: self?.presenter?.updateProfileFail()
                    case .wrongPassword: self?.presenter?.updateProfilePasswordFail()
                    default: break
                    }
                }
                
                return
            }
            
            self?.updateProfile(profile)
            
            self?.presenter?.updateProfileSuccess()
        }
    }
}

// MARK: - Private Methods

private extension ProfileInteractor {
    func updateUser(userIdentifier: String,
                    firstName: String,
                    lastName: String?,
                    email: String,
                    profileImageURL: String?) {
        let user = UserInfo(identifier: userIdentifier,
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            profileImageURL: profileImageURL)
        
        FirebaseUserService.updateUser(user)
    }
}
