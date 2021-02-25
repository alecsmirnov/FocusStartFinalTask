//
//  UIViewController+StatusBarColor.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

extension UIViewController {
    func setupStatusBarColor(_ color: UIColor) {
        let statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        let statusBarView = UIView()
        statusBarView.backgroundColor = color
        view.addSubview(statusBarView)

        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            statusBarView.heightAnchor.constraint(equalToConstant: statusBarHeight),
            statusBarView.widthAnchor.constraint(equalTo: view.widthAnchor),
            statusBarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}
