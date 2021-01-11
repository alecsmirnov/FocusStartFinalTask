//
//  ProfilePresenter.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import Foundation

protocol IProfilePresenter: AnyObject {
    func viewDidLoad()
    
    func didPressSaveButton(firstName: String?, lastName: String?, email: String?, profileImageData: Data?)
    func didPressCloseButton()
    
    func didValidatePassword(_ password: String)
}

final class ProfilePresenter {
    weak var viewController: IProfileViewController?
    var interactor: IProfileInteractor?
    var router: IProfileRouter?
    
    var user: UserInfo?
    
    private var profileUpdate: ProfileInfo?
}

// MARK: - IMenuPresenter

extension ProfilePresenter: IProfilePresenter {
    func viewDidLoad() {
        if let user = user {
            viewController?.setUser(user)
        }
    }
    
    func didPressSaveButton(firstName: String?, lastName: String?, email: String?, profileImageData: Data?) {
        guard let firstName = firstName, !firstName.isEmpty,
              let email = email, !email.isEmpty else {
            viewController?.showEmptyFieldsAlert()
            
            return
        }
        
        guard EmailValidation.isValid(email) else {
            viewController?.showInvalidEmailAlert()

            return
        }
        
        let profileUpdate = ProfileInfo(firstName: firstName,
                                        lastName: lastName,
                                        email: email,
                                        profileImageData: profileImageData)
        
        if user?.email == email {
            interactor?.updateProfile(profileUpdate)
            router?.closeProfileViewController()
        } else {
            self.profileUpdate = profileUpdate
            
            viewController?.showPasswordValidationAlertController()
        }
    }
    
    func didPressCloseButton() {
        router?.closeProfileViewController()
    }
    
    func didValidatePassword(_ password: String) {
        if let profileUpdate = profileUpdate {
            viewController?.showSpinnerView()
            
            interactor?.updateProfile(profileUpdate, withEmail: profileUpdate.email, password: password)
        }
    }
}

// MARK: - IProfileInteractorOutput

extension ProfilePresenter: IProfileInteractorOutput {
    func updateProfileSuccess() {
        viewController?.hideSpinnerView()
        router?.closeProfileViewController()
    }
    
    func updateProfileFail() {
        viewController?.hideSpinnerView()
        viewController?.showEmailAlreadyExistAlert()
    }
    
    func updateProfilePasswordFail() {
        viewController?.hideSpinnerView()
        viewController?.showWrongPasswordAlert()
    }
}
