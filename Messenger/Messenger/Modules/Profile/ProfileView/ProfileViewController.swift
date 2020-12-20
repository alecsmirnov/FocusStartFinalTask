//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

protocol IProfileViewController: AnyObject {
    func setUser(_ user: UserInfo)
    
    func showEmptyFieldsAlert()
    func showInvalidEmailAlert()
    func showEmailAlreadyExistAlert()
    func showWrongPasswordAlert()
    
    func showPasswordValidationAlertController()
    
    func showSpinnerView()
    func hideSpinnerView()
}

final class ProfileViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IProfilePresenter?
    
    private var imagePicker: ImagePicker?
    private var simpleAlertController: SimpleAlertController?
    private var passwordAlertController: PasswordAlertController?

    private var profileView: ProfileView {
        guard let view = view as? ProfileView else {
            fatalError("view is not a ProfileView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = ProfileView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        setupView()
        setupSimpleAlertController()
        setupImagePicker()
        setupPasswordAlertController()
    }
}

// MARK: - IProfileViewController

extension ProfileViewController: IProfileViewController {
    func setUser(_ user: UserInfo) {
        profileView.setUser(user)
    }
    
    func showEmptyFieldsAlert() {
        simpleAlertController?.showAlert(title: "Required fields are empty",
                                         message: "Please enter First name and Email")
    }
    
    func showInvalidEmailAlert() {
        simpleAlertController?.showAlert(title: "Invalid email address", message: "Please try again")
    }
    
    func showEmailAlreadyExistAlert() {
        simpleAlertController?.showAlert(title: "This email already exists", message: "Please try another address")
    }
    
    func showWrongPasswordAlert() {
        simpleAlertController?.showAlert(title: "Wrong password", message: "Please try another address")
    }
    
    func showPasswordValidationAlertController() {
        passwordAlertController?.showAlert()
    }
    
    func showSpinnerView() {
        profileView.showSpinnerView()
    }
    
    func hideSpinnerView() {
        profileView.hideSpinnerView()
    }
}

// MARK: - Private Methods

private extension ProfileViewController {
    func setupView() {
        profileView.delegate = self
    }
    
    func setupImagePicker() {
        imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    func setupSimpleAlertController() {
        simpleAlertController = SimpleAlertController(presentationController: self, delegate: self)
    }
    
    func setupPasswordAlertController() {
        passwordAlertController = PasswordAlertController(presentationController: self, delegate: self)
    }
}

// MARK: - ProfileViewDelegate

extension ProfileViewController: ProfileViewDelegate {
    func profileViewDidPressSaveButton(_ profileView: ProfileView) {
        let bound = CGSize(width: 60, height: 60)
        
        let compressedProfileImage = profileView.profileImage?.resize(withBounds: bound, contentMode: .aspectFill)
        
        presenter?.didPressSaveButton(firstName: profileView.firstNameText,
                                      lastName: profileView.lastNameText,
                                      email: profileView.emailText,
                                      profileImageData: compressedProfileImage?.pngData())
    }
    
    func profileViewDidPressCloseButton(_ profileView: ProfileView) {
        presenter?.didPressCloseButton()
    }
    
    func profileViewDidTapProfileImage(_ profileView: ProfileView) {
        imagePicker?.takePhoto()
    }
}

// MARK: - ImagePickerDelegate

extension ProfileViewController: ImagePickerDelegate {
    func imagePicker(_ imagePicker: ImagePicker, didSelectImage image: UIImage?) {
        profileView.profileImage = image
    }
}

// MARK: - SimpleAlertControllerDelegate

extension ProfileViewController: SimpleAlertControllerDelegate {
    func simpleAlertControllerDidPressDismiss(_ simpleAlertController: SimpleAlertController) {}
}

// MARK: - PasswordAlertControllerDelegate

extension ProfileViewController: PasswordAlertControllerDelegate {
    func passwordAlertController(_ passwordAlertController: PasswordAlertController, didPressSubmitWith text: String?) {
        if let password = text {
            presenter?.didValidatePassword(password)
        }
    }
    
    func passwordAlertControllerDidPressDismiss(_ passwordAlertController: PasswordAlertController) {}
}
