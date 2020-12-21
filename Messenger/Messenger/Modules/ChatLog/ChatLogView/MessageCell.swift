//
//  MessageCell.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IMessageCell: AnyObject {}

final class MessageCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Constants {
        static let incomingMessageColor = UIColor.black
        static let outgoingMessageColor = Colors.themeColor
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
        
        static let profileImageSize: CGFloat = 44
        
        static let bubbleViewCornerRadius: CGFloat = 16
        
        static let cellContentViewMultiplier: CGFloat = 0.7
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
    
    private let isReadMessageLabel = UILabel()
    
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

// MARK: - IMessageCell

extension MessageCell: IMessageCell {}

// MARK: - Public Methods

extension MessageCell {
    func configure(with userMessage: UserMessageInfo) {
        let message = userMessage.message
        
        switch message.type {
        case .text(let messageText): messageLabel.text = messageText
        }
        
        if message.isRead {
            isReadMessageLabel.text = "read"
            isReadMessageLabel.textColor = .green
        } else {
            isReadMessageLabel.text = "no"
            isReadMessageLabel.textColor = .red
        }
        
        if message.isIncoming ?? false {
            setupCellContentViewLeadingLayout()
            
            profileImageImageView.isHidden = false
            profileImageImageView.backgroundColor = .black
            
            messageLabel.textColor = .white
            
            bubbleView.backgroundColor = Constants.incomingMessageColor
            
            if let sender = userMessage.sender {
                profileImageImageView.showInitials(firstName: sender.firstName, lastName: sender.lastName)
                profileImageImageView.backgroundColor = .black
                
                if let profileImageURL = sender.profileImageURL {
                    profileImageImageView.download(urlString: profileImageURL)
                }
            }
        } else {
            setupCellContentViewTrailingLayout()
            
            profileImageImageView.isHidden = true
            
            messageLabel.textColor = .black
            
            bubbleView.backgroundColor = Constants.outgoingMessageColor
        }
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
        messageLabel.font = .systemFont(ofSize: 14)
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.textAlignment = .right
        timestampLabel.textColor = .systemGray
        timestampLabel.font = .systemFont(ofSize: 10)
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
        
        setupIsReadMessageLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        cellContentView.addSubview(bubbleView)
        
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timestampLabel)
        bubbleView.addSubview(isReadMessageLabel)
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
            constant: 5
        )
    }
    
    func prepareCellContentViewTrailingLayout() {
        cellContentViewTrailingConstraint = cellContentView.trailingAnchor.constraint(
            equalTo: contentView.trailingAnchor,
            constant: -5
        )
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor,
                                                          constant: -Metrics.verticalSpace),
            profileImageImageView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor,
                                                           constant: 10),
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
                                                constant: 5),
            bubbleView.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor,
                                                 constant: -5),
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
            timestampLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor,
                                                    constant: Metrics.horizontalSpace),
            timestampLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor,
                                                     constant: -Metrics.horizontalSpace),
        ])
    }
    
    
    func setupIsReadMessageLabelLayout() {
        isReadMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            isReadMessageLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor,
                                                    constant: Metrics.verticalSpace),
            isReadMessageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor,
                                                       constant: -Metrics.verticalSpace),
            isReadMessageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor,
                                                        constant: Metrics.horizontalSpace),
            isReadMessageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor,
                                                         constant: -Metrics.horizontalSpace),
        ])
    }
}
