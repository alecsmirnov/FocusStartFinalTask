//
//  MenuView.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import UIKit

protocol IMenuView: AnyObject {
    var profilePhotoTapAction: Completions.ButtonPress? { get set }
    var signOutButtonAction: Completions.ButtonPress? { get set }
}

final class MenuView: UIView {
    // MARK: Properties
    
    var profilePhotoTapAction: Completions.ButtonPress?
    var signOutButtonAction: Completions.ButtonPress?
    
    private enum Metrics {
        static let profilePhotoHeight: CGFloat = 54
        static let profilePhotoWidth: CGFloat = 54
    }
    
    // MARK: Subviews
    
    private let profilePhotoImageView = UIImageView()
    private let signOutButton = UIButton(type: .system)
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawProfilePhotoImageView()
    }
}

// MARK: - IMenuView

extension MenuView: IMenuView {}

// MARK: - Draw

private extension MenuView {
    func drawProfilePhotoImageView() {
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.height / 2
        profilePhotoImageView.clipsToBounds = true
    }
}

// MARK: - Appearance

private extension MenuView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupProfilePhotoImageViewAppearance()
        setupSignOutButtonAppearance()
    }
    
    func setupProfilePhotoImageViewAppearance() {
        profilePhotoImageView.contentMode = .scaleAspectFill
        profilePhotoImageView.backgroundColor = .systemGray3
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        
        profilePhotoImageView.isUserInteractionEnabled = true
        profilePhotoImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupSignOutButtonAppearance() {
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.clipsToBounds = true
        signOutButton.sizeToFit()
        
        signOutButton.addTarget(self, action: #selector(didPressSignOutButton), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension MenuView {
    @objc func didTapProfileImageView() {
        profilePhotoTapAction?()
    }
    
    @objc func didPressSignOutButton() {
        signOutButtonAction?()
    }
}

// MARK: - Layout

private extension MenuView {
    func setupLayout() {
        setupSubviews()
        
        setupProfilePhotoImageViewLayout()
        setupSignOutButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(profilePhotoImageView)
        addSubview(signOutButton)
    }
    
    func setupProfilePhotoImageViewLayout() {
        profilePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePhotoImageView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor),
            profilePhotoImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: Metrics.profilePhotoHeight),
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: Metrics.profilePhotoWidth),
        ])
    }
    
    func setupSignOutButtonLayout() {
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signOutButton.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            signOutButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}
