//
//  MessageCell.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IMessageCell: AnyObject {}

final class MessageCell: UICollectionViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
        
        static let profileImageSize: CGFloat = 44
        
        static let bubbleViewCornerRadius: CGFloat = 16
        
        static let profileImageBubbleViewHorizontalSpace: CGFloat = 8
    }
    
    private var contentViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: Subviews
    
    private let bubbleView = UIView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timestampLabel = UILabel()
    
    private let profileImageImageView = UIImageView()
    
    // MARK: Lifecycle
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateLayout()
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - IMessageCell

extension MessageCell: IMessageCell {}

// MARK: - Public Methods

extension MessageCell {
    func configure(firstName: String, lastName: String?, messageText: String) {
        nameLabel.text = "\(firstName) \(lastName ?? "")"
        messageLabel.text = messageText
        timestampLabel.text = ""
    }
}

// MARK: - Appearance

private extension MessageCell {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupBubbleViewAppearance()
        setupNameLabelAppearance()
        setupMessageLabelAppearance()
        
        setupProfileImageImageViewAppearance()
    }
    
    func setupBubbleViewAppearance() {
        bubbleView.backgroundColor = .systemGray5
        bubbleView.layer.cornerRadius = Metrics.bubbleViewCornerRadius
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: nameLabel.font.pointSize)
    }
    
    func setupMessageLabelAppearance() {
        messageLabel.numberOfLines = 0
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.layer.borderWidth = 1
        profileImageImageView.layer.borderColor = UIColor.systemGray.cgColor
        profileImageImageView.layer.cornerRadius = Metrics.profileImageSize / 2
        profileImageImageView.clipsToBounds = true
    }
}

// MARK: - Layout

private extension MessageCell {
    func setupLayout() {
        setupSubviews()
        
        setupContentViewLayout()
        setupBubbleViewLayout()
        setupProfileImageImageViewLayout()
        
        setupNameLabelLayout()
        setupMessageLabelLayout()
        setupTimestampLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(bubbleView)
        contentView.addSubview(profileImageImageView)
        
        bubbleView.addSubview(nameLabel)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timestampLabel)
    }
    
    func setupContentViewLayout() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: bounds.size.width)
        contentViewWidthConstraint?.isActive = true
    }
    
    func setupBubbleViewLayout() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.verticalSpace),
            bubbleView.bottomAnchor.constraint(equalTo: profileImageImageView.bottomAnchor),
            bubbleView.leadingAnchor.constraint(equalTo: profileImageImageView.trailingAnchor,
                                                constant: Metrics.profileImageBubbleViewHorizontalSpace),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                 constant: -Metrics.horizontalSpace),
        ])
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            profileImageImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                           constant: Metrics.horizontalSpace),
            profileImageImageView.heightAnchor.constraint(equalToConstant: Metrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: Metrics.profileImageSize),
        ])
    }
    
    func setupNameLabelLayout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Metrics.verticalSpace),
            nameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Metrics.horizontalSpace),
            nameLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Metrics.horizontalSpace),
        ])
    }
    
    func setupMessageLabelLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Metrics.horizontalSpace),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor,
                                                   constant: -Metrics.horizontalSpace),
        ])
    }
    
    func setupTimestampLabelLayout() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timestampLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.verticalSpace),
            timestampLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Metrics.verticalSpace),
            timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor,
                                                    constant: Metrics.horizontalSpace),
            timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor,
                                                     constant: -Metrics.horizontalSpace),
        ])
    }
}

// MARK: - Update Layout

private extension MessageCell {
    func updateLayout() {
        contentViewWidthConstraint?.constant = UIScreen.main.bounds.width
    }
}

extension MessageCell {
    override func systemLayoutSizeFitting(_ targetSize: CGSize,
                                          withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
                                          verticalFittingPriority: UILayoutPriority) -> CGSize {
        return contentView.systemLayoutSizeFitting(targetSize)
    }
}
