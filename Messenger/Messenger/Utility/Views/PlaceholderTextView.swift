//
//  PlaceholderTextView.swift
//  Messenger
//
//  Created by Admin on 21.12.2020.
//

import UIKit

final class PlaceholderTextView: UITextView {
    // MARK: Properties
    
    private enum Constants {
        static let placeholderLabelColor = UIColor.lightGray
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 4
        static let horizontalSpace: CGFloat = 4
    }
    
    // MARK: Subviews
    
    private let placeholderLabel = UILabel()
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        
        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension PlaceholderTextView {
    var placeholderText: String? {
        get { placeholderLabel.text }
        set { placeholderLabel.text = newValue }
    }
    
    func showPlaceholder() {
        placeholderLabel.isHidden = false
    }
    
    func hidePlaceholder() {
        placeholderLabel.isHidden = true
    }
}

// MARK: - Appearance

private extension PlaceholderTextView {
    func setupAppearance() {
        placeholderLabel.textColor = Constants.placeholderLabelColor
    }
}

// MARK: - Layout

private extension PlaceholderTextView {
    func setupLayout() {
        setupSubviews()
        
        setupPlaceholderLabelLayout()
    }
    
    func setupSubviews() {
        addSubview(placeholderLabel)
    }
    
    func setupPlaceholderLabelLayout() {
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor,
                                                  constant: Metrics.verticalSpace),
            placeholderLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -Metrics.verticalSpace),
            placeholderLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                      constant: Metrics.horizontalSpace),
            placeholderLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                       constant: -Metrics.horizontalSpace),
        ])
    }
}
