//
//  LaunchView.swift
//  Messenger
//
//  Created by Admin on 06.12.2020.
//

import UIKit

protocol ILaunchView: AnyObject {}

final class LaunchView: UIView {
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)
        
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ILaunchView

extension LaunchView: ILaunchView {}

// MARK: - Appearance

private extension LaunchView {
    func setupAppearance() {
        backgroundColor = .systemBackground
    }
}
