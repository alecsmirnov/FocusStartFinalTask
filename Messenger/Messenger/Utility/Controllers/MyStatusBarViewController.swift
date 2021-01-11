//
//  MyStatusBarViewController.swift
//  Messenger
//
//  Created by Admin on 21.12.2020.
//

import UIKit

class MyStatusBarViewController: UIViewController {
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupStatusBarColor()
    }
}

// MARK: - Appearance

private extension MyStatusBarViewController {
    func setupStatusBarColor() {
        setupStatusBarColor(Colors.themeColor)
    }
}
