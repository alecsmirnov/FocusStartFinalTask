//
//  MenuInteractor.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import Foundation

protocol IMenuInteractor: AnyObject {
    func uploadProfileImageData(_ data: Data)
    
    func signOut()
}

protocol IMenuInteractorOutput: AnyObject {}

final class MenuInteractor {
    weak var presenter: IMenuInteractorOutput?
}

// MARK: - IMenuInteractor

extension MenuInteractor: IMenuInteractor {
    func uploadProfileImageData(_ data: Data) {
        guard let userIdentifier = FirebaseAuthService.currentUser()?.uid else { return }
        
        FirebaseStorageService.uploadProfileImageData(data, userIdentifier: userIdentifier) { error in
            guard error == nil else {
                return
            }
            
//            FirebaseStorageService.downloadProfileImageDataURL(userIdentifier: userIdentifier) { urlString, error in
//                guard let urlString = urlString, error == nil else {
//                    return
//                }
//                
//                FirebaseDatabaseService.updateUserInfo(for: userIdentifier, key: .profilePhotoURL, value: urlString)
//            }
        }
    }
    
    func signOut() {
        FirebaseAuthService.signOut()
    }
}
