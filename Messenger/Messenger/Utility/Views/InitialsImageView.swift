//
//  InitialsImageView.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

final class InitialsImageView: UIImageView {
    // MARK: Properties
    
    override var image: UIImage? {
        didSet {
            if image != nil {
                hideInitials()
            }
        }
    }
    
    // MARK: Subviews
    
    private lazy var initialsLabel: UILabel = {
        let initialsLabel = UILabel()
        
        initialsLabel.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        initialsLabel.textAlignment = .center
        initialsLabel.textColor = .white
        initialsLabel.font = .boldSystemFont(ofSize: initialsLabel.font.pointSize)
        
        return initialsLabel
    }()
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension InitialsImageView {
    func showInitials(firstName: String, lastName: String?) {
        if let firstLetter = firstName.first {
            var secondLetter: String?
            
            if let secondChar = lastName?.first {
                secondLetter = String(secondChar)
            }
        
            initialsLabel.text = String(firstLetter) + (secondLetter ?? "")
        
            initialsLabel.isHidden = false
        }
    }
}

// MARK: - Private Methods

private extension InitialsImageView {
    func hideInitials() {
        initialsLabel.isHidden = true
    }
}

// MARK: - Layout

private extension InitialsImageView {
    func setupLayout() {
        setupSubviews()
        
        setupInitialsLabelLayout()
    }
    
    func setupSubviews() {
        addSubview(initialsLabel)
    }
    
    func setupInitialsLabelLayout() {
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            initialsLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            initialsLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            initialsLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            initialsLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
