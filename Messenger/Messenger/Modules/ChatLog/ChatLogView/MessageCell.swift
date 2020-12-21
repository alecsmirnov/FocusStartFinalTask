//
//  MessageCell.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

final class MessageCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Constants {
        static let incomingMessageColor = Colors.themeAdditionalColor
        static let outgoingMessageColor = Colors.themeColor
        
        static let incomingMessageTextColor = UIColor.white
        static let outgoingMessageTextColor = UIColor.black
        
        static let messageLabelFontSize: CGFloat = 16
        static let timestampLabelFontSize: CGFloat = 12
        
        static let timestampLabelTextColor = UIColor.white
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
        
        static let profileImageLeftSpace: CGFloat = 10
        static let profileImageSize: CGFloat = 44
        
        static let bubbleViewHorizontalSpace: CGFloat = 5
        static let bubbleViewCornerRadius: CGFloat = 16
        
        static let cellContentViewMultiplier: CGFloat = 0.7
        
        static let timestampLabelRightSpace: CGFloat = 7
    }
    
    // MARK: Constraints
    
    private var cellContentViewLeadingConstraint: NSLayoutConstraint?
    private var cellContentViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: Subviews
    
    private let profileImageView = UIView()
    private let cellContentView = UIView()
    
    private let profileImageImageView = InitialsImageView()
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timestampLabel = UILabel()
    
    // MARK: Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupAppearance()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension MessageCell {
    func configure(with userMessage: UserMessageInfo) {
        setMessage(userMessage.message)
        
        if userMessage.message.isIncoming ?? false {
            setupIncomingAppearance()
            setSenderInfo(userMessage.sender)
        } else {
            setupOutgoingAppearance()
        }
    }
}

// MARK: - Private Methods

private extension MessageCell {
    func setMessage(_ message: MessageInfo) {
        switch message.type {
        case .text(let messageText): messageLabel.text = messageText
        }
        
        timestampLabel.text = Date(timeIntervalSince1970: message.timestamp).daytimeString()
    }
    
    func setSenderInfo(_ sender: UserInfo?) {
        if let sender = sender {
            profileImageImageView.showInitials(firstName: sender.firstName, lastName: sender.lastName)
            profileImageImageView.backgroundColor = Colors.initialsViewBackgroundColor
            
            if let profileImageURL = sender.profileImageURL {
                profileImageImageView.download(urlString: profileImageURL)
            }
        }
    }
    
    func setupIncomingAppearance() {
        setupCellContentViewLeadingLayout()
        
        profileImageImageView.isHidden = false
        profileImageImageView.backgroundColor = .black
        
        messageLabel.textColor = Constants.incomingMessageTextColor
        bubbleView.backgroundColor = Constants.incomingMessageColor
    }
    
    func setupOutgoingAppearance() {
        setupCellContentViewTrailingLayout()
        
        profileImageImageView.isHidden = true
        
        messageLabel.textColor = Constants.outgoingMessageTextColor
        bubbleView.backgroundColor = Constants.outgoingMessageColor
    }
}

// MARK: - Appearance

private extension MessageCell {
    func setupAppearance() {
        backgroundColor = .clear
        
        setupProfileImageImageViewAppearance()
        setupBubbleViewAppearance()
        setupMessageLabelAppearance()
        setupTimestampLabelAppearance()
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.layer.borderWidth = 1
        profileImageImageView.layer.borderColor = UIColor.systemGray.cgColor
        profileImageImageView.layer.cornerRadius = Metrics.profileImageSize / 2
        profileImageImageView.clipsToBounds = true
    }
    
    func setupBubbleViewAppearance() {
        bubbleView.layer.cornerRadius = Metrics.bubbleViewCornerRadius
    }
    
    func setupMessageLabelAppearance() {
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: Constants.messageLabelFontSize)
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.textAlignment = .right
        timestampLabel.textColor = Constants.timestampLabelTextColor
        timestampLabel.font = .systemFont(ofSize: Constants.timestampLabelFontSize)
    }
}

// MARK: - Layout

private extension MessageCell {
    func setupLayout() {
        setupSubviews()
        
        setupProfileImageViewLayout()
        setupCellContentViewLayout()
        
        setupProfileImageImageViewLayout()
        setupBubbleViewLayout()
        setupMessageLabelLayout()
        setupTimestampLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        cellContentView.addSubview(bubbleView)
        
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timestampLabel)
    }
    
    func setupProfileImageViewLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }
    
    func setupCellContentViewLayout() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            cellContentView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor,
                                                   multiplier: Metrics.cellContentViewMultiplier),
        ])
        
        prepareCellContentViewLeadingLayout()
        prepareCellContentViewTrailingLayout()
        
        setupCellContentViewLeadingLayout()
    }
    
    func setupCellContentViewLeadingLayout() {
        cellContentViewTrailingConstraint?.isActive = false
        cellContentViewLeadingConstraint?.isActive = true
    }
    
    func setupCellContentViewTrailingLayout() {
        cellContentViewLeadingConstraint?.isActive = false
        cellContentViewTrailingConstraint?.isActive = true
    }
    
    func prepareCellContentViewLeadingLayout() {
        cellContentViewLeadingConstraint = cellContentView.leadingAnchor.constraint(
            equalTo: profileImageImageView.trailingAnchor,
            constant: Metrics.bubbleViewHorizontalSpace
        )
    }
    
    func prepareCellContentViewTrailingLayout() {
        cellContentViewTrailingConstraint = cellContentView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -Metrics.bubbleViewHorizontalSpace
        )
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor,
                                                          constant: -Metrics.verticalSpace),
            profileImageImageView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor,
                                                           constant: Metrics.profileImageLeftSpace),
            profileImageImageView.heightAnchor.constraint(equalToConstant: Metrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: Metrics.profileImageSize),
        ])
    }
    
    func setupBubbleViewLayout() {
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: cellContentView.topAnchor, constant: Metrics.verticalSpace),
            bubbleView.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor, constant: -Metrics.verticalSpace),
            bubbleView.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor,
                                                constant: Metrics.bubbleViewHorizontalSpace),
            bubbleView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor,
                                                 constant: -Metrics.bubbleViewHorizontalSpace),
        ])
    }
    
    func setupMessageLabelLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: Metrics.verticalSpace),
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
                                                     constant: -Metrics.timestampLabelRightSpace),
        ])
    }
}
