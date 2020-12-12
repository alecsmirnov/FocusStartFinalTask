//
//  MenuViewController.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import UIKit

protocol IMenuViewController: AnyObject {
    func takePhoto()
}

final class MenuViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IMenuPresenter?
    
    private var menuView: IMenuView {
        guard let view = view as? MenuView else {
            fatalError("view is not a MenuView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = MenuView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad(view: menuView)
    }
}

// MARK: - IMenuViewController

extension MenuViewController: IMenuViewController {
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MenuViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
              let data = image.pngData() else {
            picker.dismiss(animated: true)
            
            return
        }
        
        presenter?.didSelectImage(with: data)
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension MenuViewController {
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
    
        present(alertController, animated: true)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
}
