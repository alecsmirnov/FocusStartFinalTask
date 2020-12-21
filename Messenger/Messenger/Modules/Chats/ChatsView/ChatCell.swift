//
//  ChatCell.swift
//  Messenger
//
//  Created by Admin on 25.11.2020.
//

import UIKit

protocol IChatsCell: AnyObject {}

final class ChatCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Metrics {
        static let cellContentHeight: CGFloat = 50
        static let cellContentTopSpace: CGFloat = 16
        static let cellContentBottomSpace: CGFloat = 14
        static let cellContentRightSpace: CGFloat = 10
        
        static let profileImageHorizontalSpace: CGFloat = 10
        static let profileImageSize: CGFloat = 54
        
        static let nameMessageSpace: CGFloat = 6
        
        static let nameLabelFontSize: CGFloat = 17
        static let timestampLabelFontSize: CGFloat = 14
        static let messageLabelFontSize: CGFloat = 16
        
        static let unreadMessagesCountLabelSize: CGFloat = 16
    }
    
    private enum LayoutPriority {
        static let bottom: Float = 750
    }
    
    // MARK: Subviews
    
    private let profileImageView = UIView()
    private let profileImageImageView = InitialsImageView()
    private let onlineStatusView = UIView()
    
    private let cellContentView = UIView()
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let unreadMessagesCountLabel = UILabel()
    private let timestampLabel = UILabel()
    
    // MARK: Lifecycle
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawProfileImageImageView()
    }
    
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

// MARK: - IChatCell

extension ChatCell: IChatsCell {}

// MARK: - Public Methods

extension ChatCell {
    func configure(with chat: ChatInfo) {
        nameLabel.text = "\(chat.companion.firstName) \(chat.companion.lastName ?? "")"
        
        if let latestMessage = chat.latestMessage {
            switch latestMessage.type {
            case .text(let messageText): messageLabel.text = messageText
            }
            
            if let latestMessageTimestamp = chat.latestMessage?.timestamp {
                timestampLabel.text = Date(timeIntervalSince1970: latestMessageTimestamp).formatRelativeString()
            }
        } else {
            messageLabel.text = nil
            timestampLabel.text = nil
        }

        unreadMessagesCountLabel.isHidden = chat.unreadMessagesCount == nil || 0 == chat.unreadMessagesCount ?? 0
        unreadMessagesCountLabel.text = chat.unreadMessagesCount?.description
        
        profileImageImageView.showInitials(firstName: chat.companion.firstName, lastName: chat.companion.lastName)
        profileImageImageView.backgroundColor = .black
        
        if let profileImageURL = chat.companion.profileImageURL {
            profileImageImageView.download(urlString: profileImageURL)
        }
        
        onlineStatusView.isHidden = !(chat.isOnline ?? false)
    }
}

// MARK: - Draw

private extension ChatCell {
    func drawProfileImageImageView() {
        profileImageImageView.layer.cornerRadius = profileImageImageView.frame.size.height / 2
        profileImageImageView.clipsToBounds = true
    }
}

// MARK: - Appearance

private extension ChatCell {
    func setupAppearance() {
        setupProfileImageImageViewAppearance()
        setupOnlineStatusViewAppearance()
        setupNameLabelAppearance()
        setupMessageLabelAppearance()
        setupUnreadMessagesCountLabelAppearance()
        setupTimestampLabelAppearance()
        
        setupSeparatorAppearance()
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.contentMode = .scaleAspectFill
    }
    
    func setupOnlineStatusViewAppearance() {
        onlineStatusView.backgroundColor = UIColor(red: 0.0549, green: 0.9274, blue: 0.7647, alpha: 1)
        onlineStatusView.layer.borderWidth = 1
        onlineStatusView.layer.borderColor = Colors.themeColor.cgColor
        onlineStatusView.layer.cornerRadius = 6
        onlineStatusView.layer.masksToBounds = true
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: Metrics.nameLabelFontSize)
        nameLabel.numberOfLines = 1
    }
    
    func setupMessageLabelAppearance() {
        messageLabel.font = .systemFont(ofSize: Metrics.messageLabelFontSize)
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 1
    }
    
    func setupUnreadMessagesCountLabelAppearance() {
        unreadMessagesCountLabel.textAlignment = .center
        unreadMessagesCountLabel.textColor = .white
        unreadMessagesCountLabel.font = .systemFont(ofSize: 12)
        unreadMessagesCountLabel.layer.masksToBounds = true
        unreadMessagesCountLabel.layer.cornerRadius = Metrics.unreadMessagesCountLabelSize / 2
        unreadMessagesCountLabel.backgroundColor = UIColor(red: 0.7215, green: 0.1176, blue: 0.2431, alpha: 0.9)
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.font = .systemFont(ofSize: Metrics.timestampLabelFontSize)
        timestampLabel.textColor = .darkGray
        timestampLabel.textAlignment = .right
        timestampLabel.numberOfLines = 1
    }
    
    func setupSeparatorAppearance() {
        let leftInset = Metrics.profileImageSize + Metrics.profileImageHorizontalSpace * 2
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
    }
}

// MARK: - Layout

private extension ChatCell {
    func setupLayout() {
        setupSubviews()
        
        setupProfileImageViewLayout()
        setupCellContentViewLayout()
        
        setupProfileImageImageViewLayout()
        setupOnlineStatusViewLayout()
        setupNameLabelLayout()
        setupMessageLabelLayout()
        setupTimestampLabelLayout()
        setupUnreadMessagesCountLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        profileImageView.addSubview(onlineStatusView)
        
        cellContentView.addSubview(nameLabel)
        cellContentView.addSubview(messageLabel)
        cellContentView.addSubview(unreadMessagesCountLabel)
        cellContentView.addSubview(timestampLabel)
    }
    
    func setupProfileImageViewLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        ])
    }
    
    func setupOnlineStatusViewLayout() {
        onlineStatusView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            //onlineStatusView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: -Metrics.profileImageHorizontalSpace),
            //onlineStatusView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -10),
            onlineStatusView.centerXAnchor.constraint(equalTo: profileImageImageView.trailingAnchor, constant: -Metrics.profileImageHorizontalSpace + 2),
            onlineStatusView.centerYAnchor.constraint(equalTo: profileImageImageView.bottomAnchor, constant: -Metrics.profileImageHorizontalSpace + 1),
            onlineStatusView.widthAnchor.constraint(equalToConstant: 12),
            onlineStatusView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
    
    func setupCellContentViewLayout() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        let cellContentViewBottomConstraint = cellContentView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -Metrics.cellContentBottomSpace
        )
        cellContentViewBottomConstraint.priority = UILayoutPriority(LayoutPriority.bottom)
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.cellContentTopSpace),
            cellContentViewBottomConstraint,
            cellContentView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Metrics.cellContentRightSpace),
            cellContentView.heightAnchor.constraint(equalToConstant: Metrics.cellContentHeight),
        ])
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            profileImageImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            profileImageImageView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor,
                                                           constant: Metrics.profileImageHorizontalSpace),
            profileImageImageView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor,
                                                            constant: -Metrics.profileImageHorizontalSpace),
            profileImageImageView.heightAnchor.constraint(equalToConstant: Metrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: Metrics.profileImageSize),
        ])
    }
    
    func setupNameLabelLayout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: cellContentView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
        ])
    }
    
    func setupMessageLabelLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.nameMessageSpace),
            messageLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
        ])
    }
    
    func setupUnreadMessagesCountLabelLayout() {
        unreadMessagesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            unreadMessagesCountLabel.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            unreadMessagesCountLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8),
            unreadMessagesCountLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
            unreadMessagesCountLabel.widthAnchor.constraint(equalToConstant: Metrics.unreadMessagesCountLabelSize),
            unreadMessagesCountLabel.heightAnchor.constraint(equalToConstant: Metrics.unreadMessagesCountLabelSize),
        ])
    }
    
    func setupTimestampLabelLayout() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            timestampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
        ])
    }
}
