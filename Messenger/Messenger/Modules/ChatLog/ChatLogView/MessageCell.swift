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
        
        static let avatarSize: CGFloat = 44
    }
    
    private var isProcessed: Bool = false
    
    // MARK: Subviews
    
    private let bubbleView = UIView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let dateLabel = UILabel()
    
    private let avatarImageView = UIImageView()
    
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
        dateLabel.text = ""
        
        avatarImageView.image = UIImage(systemName: "person")
    }
}

// MARK: - Appearance

private extension MessageCell {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupBubbleViewAppearance()
        setupNameLabelAppearance()
    }
    
    func setupBubbleViewAppearance() {
        bubbleView.backgroundColor = .systemGray5
        
        bubbleView.layer.cornerRadius = 16
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: nameLabel.font.pointSize)
    }
}

// MARK: - Layout

private extension MessageCell {
    func setupLayout() {
        setupSubviews()
        
        setupBubbleViewLayout()
        setupNameLabelLayout()
        setupMessageLabelLayout()
        setupDateLabelLayout()
        
        setupAvatarImageViewLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(bubbleView)
        contentView.addSubview(avatarImageView)
        
        bubbleView.addSubview(nameLabel)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(dateLabel)
        bubbleView.addSubview(avatarImageView)
    }
    
    func setupBubbleViewLayout() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.verticalSpace),
            bubbleView.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor,
                                                 constant: -Metrics.horizontalSpace),
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
    
    func setupDateLabelLayout() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: Metrics.verticalSpace),
            dateLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -Metrics.verticalSpace),
            dateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: Metrics.horizontalSpace),
            dateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -Metrics.horizontalSpace),
        ])
    }
    
    func setupAvatarImageViewLayout() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: Metrics.horizontalSpace),
            avatarImageView.heightAnchor.constraint(equalToConstant: Metrics.avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: Metrics.avatarSize),
        ])
    }
}

// MARK: - Autoresize Content

extension MessageCell {
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let contentViewSize = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        
        var cellFrame = layoutAttributes.frame
        cellFrame.size = CGSize(width: UIScreen.main.bounds.width, height: contentViewSize.height)
        
        layoutAttributes.frame = cellFrame
        
        return layoutAttributes
    }
}
