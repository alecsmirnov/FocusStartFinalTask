//
//  MyViewController.swift
//  Messenger
//
//  Created by Admin on 21.12.2020.
//

import UIKit

class MyNavigationBarViewController: UIViewController {
    // MARK: Properties
    
    private enum Constants {
        static let backIndicatorImage = UIImage(systemName: "arrow.backward")
        static let backButtonTitle = ""
        
        static let titleColor = UIColor.white
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationControllerAppearance()
    }
}

// MARK: - Appearance

private extension MyNavigationBarViewController {
    func setupNavigationControllerAppearance() {
        navigationController?.navigationBar.barTintColor = Colors.themeColor
        navigationController?.navigationBar.tintColor = Colors.navigationBarButtonColor
        
        navigationController?.navigationBar.backIndicatorImage = Constants.backIndicatorImage
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = Constants.backIndicatorImage
        navigationController?.navigationBar.topItem?.title = Constants.backButtonTitle
        
        let titleColor = [NSAttributedString.Key.foregroundColor: Constants.titleColor]
        navigationController?.navigationBar.titleTextAttributes = titleColor
    }
}
