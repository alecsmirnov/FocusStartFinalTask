//
//  PlaceholderTextView.swift
//  Messenger
//
//  Created by Admin on 21.12.2020.
//

import UIKit

protocol InputTextViewDelegate: AnyObject {
    func inputTextViewDidPressSendButton(_ textView: InputTextView)
}

final class InputTextView: UITextView {
    // MARK: Properties
    
    weak var sendDelegate: InputTextViewDelegate?
    
    private enum Constants {
        static let placeholderLabelColor = UIColor.lightGray
        
        static let sendButtonImage = UIImage(systemName: "paperplane")
        static let sendButtonAnimationDuration = 0.15
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 4
        static let horizontalSpace: CGFloat = 4
        
        static let sendButtonBottomSpace: CGFloat = 6
    }
    
    // MARK: Subviews
    
    private let placeholderLabel = UILabel()
    private let sendButton = UIButton(type: .system)
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        
        setupAppearance()
        setupActions()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension InputTextView {
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
    
    func showSendButton() {
        UIView.animate(withDuration: Constants.sendButtonAnimationDuration) {
            self.sendButton.alpha = 1
        }
    }
    
    func hideSendButton() {
        UIView.animate(withDuration: Constants.sendButtonAnimationDuration) {
            self.sendButton.alpha = 0
        }
    }
}

// MARK: - Appearance

private extension InputTextView {
    func setupAppearance() {
        setupPlaceholderLabelAppearance()
        setupSendButtonAppearance()
    }
    
    func setupPlaceholderLabelAppearance() {
        placeholderLabel.textColor = Constants.placeholderLabelColor
    }
    
    func setupSendButtonAppearance() {
        sendButton.setImage(Constants.sendButtonImage, for: .normal)
        sendButton.tintColor = Colors.themeAdditionalColor
        sendButton.sizeToFit()
        
        hideSendButton()
    }
}

// MARK: - Actions

private extension InputTextView {
    func setupActions() {
        sendButton.addTarget(self, action: #selector(didPressSendButton), for: .touchUpInside)
    }
    
    @objc func didPressSendButton() {
        sendDelegate?.inputTextViewDidPressSendButton(self)
    }
}

// MARK: - Layout

private extension InputTextView {
    func setupLayout() {
        setupSubviews()
        
        setupPlaceholderLabelLayout()
        setupTestButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(placeholderLabel)
        addSubview(sendButton)
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
    
    func setupTestButtonLayout() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                               constant: -Metrics.sendButtonBottomSpace),
            sendButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                 constant: -Metrics.horizontalSpace),
        ])
    }
}
