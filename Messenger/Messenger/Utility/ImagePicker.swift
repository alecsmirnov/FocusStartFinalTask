//
//  ImagePicker.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

protocol ImagePickerDelegate: AnyObject {
    func imagePicker(_ imagePicker: ImagePicker, didSelectImage image: UIImage?)
}

final class ImagePicker: NSObject {
    // MARK: Properties
    
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        return imagePickerController
    }()
    
    // MARK: Initialization
    
    init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        super.init()

        self.presentationController = presentationController
        self.delegate = delegate
    }
}

// MARK: - Public Methods

extension ImagePicker {
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
}

// MARK: - Private Methods

private extension ImagePicker {
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        let photoAlertAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
            self?.takePhotoWithCamera()
        }
        
        let libraryAlertAction = UIAlertAction(title: "Choose From Library", style: .default) { [weak self] _ in
            self?.choosePhotoFromLibrary()
        }
        
        alertController.addAction(cancelAlertAction)
        alertController.addAction(photoAlertAction)
        alertController.addAction(libraryAlertAction)
    
        presentationController?.present(alertController, animated: true)
    }
    
    func takePhotoWithCamera() {
        imagePickerController.sourceType = .camera
        
        presentationController?.present(imagePickerController, animated: true)
    }
    
    func choosePhotoFromLibrary() {
        imagePickerController.sourceType = .photoLibrary
        
        presentationController?.present(imagePickerController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            picker.dismiss(animated: true)
            
            return
        }
        
        delegate?.imagePicker(self, didSelectImage: image)
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
