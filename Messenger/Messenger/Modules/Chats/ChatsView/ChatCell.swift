//
//  ChatCell.swift
//  Messenger
//
//  Created by Admin on 25.11.2020.
//

import UIKit

final class ChatCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Constants {
        static let nameLabelFontSize: CGFloat = 17
        static let timestampLabelFontSize: CGFloat = 14
        static let messageLabelFontSize: CGFloat = 16
        
        static let onlineStatusViewBorderWidth: CGFloat = 2
        static let onlineStatusViewBackgroundColor = UIColor(red: 0.0549, green: 0.9274, blue: 0.7647, alpha: 1)
        
        static let unreadMessagesCountLabelFontSize: CGFloat = 12

        static let outgoingLabelText = "You:"
    }
    
    private enum Metrics {
        static let cellContentHeight: CGFloat = 50
        static let cellContentTopSpace: CGFloat = 16
        static let cellContentBottomSpace: CGFloat = 14
        static let cellContentRightSpace: CGFloat = 10
        
        static let profileImageHorizontalSpace: CGFloat = 10
        
        static let nameMessageSpace: CGFloat = 6
        
        static let outgoingLabelMessageSpace: CGFloat = 4
        
        static let onlineStatusViewCenterX: CGFloat = profileImageHorizontalSpace - 2
        static let onlineStatusViewCenterY: CGFloat = profileImageHorizontalSpace - 1
        static let onlineStatusViewSize: CGFloat = 12
        
        static let unreadMessagesCountLabelSize: CGFloat = 16
        static let unreadMessagesCountLabelLeftSpace: CGFloat = 8
    }
    
    private enum LayoutPriority {
        static let bottom: Float = 750
    }
    
    private var messageLabelLeadingConstraint: NSLayoutConstraint?
    private var outgoingLabelConstraints = [NSLayoutConstraint]()
    
    // MARK: Subviews
    
    private let profileImageView = UIView()
    private let profileImageImageView = InitialsImageView()
    private let onlineStatusView = UIView()
    
    private let cellContentView = UIView()
    private let nameLabel = UILabel()
    private let outgoingLabel = UILabel()
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

// MARK: - Public Methods

extension ChatCell {
    func configure(with chat: ChatInfo) {
        setSenderInfo(chat.companion)
        setMessage(chat.latestMessage)
        setUnreadMessagesCount(chat.unreadMessagesCount)
        setOnlineStatus(chat.isOnline)
    }
}

// MARK: - Private Methods

private extension ChatCell {
    func setSenderInfo(_ sender: UserInfo) {
        nameLabel.text = "\(sender.firstName) \(sender.lastName ?? "")"
        
        profileImageImageView.showInitials(firstName: sender.firstName, lastName: sender.lastName)
        profileImageImageView.backgroundColor = Colors.initialsViewBackgroundColor
        
        if let profileImageURL = sender.profileImageURL {
            profileImageImageView.download(urlString: profileImageURL)
        }
    }
    
    func setMessage(_ message: MessageInfo?) {
        if let message = message {
            switch message.type {
            case .text(let messageText): messageLabel.text = messageText
            }
            
            timestampLabel.text = Date(timeIntervalSince1970: message.timestamp).formatRelativeString()
            
            if message.isIncoming ?? true {
                hideOutgoingLabel()
            } else {
                showOutgoingLabel()
            }
        } else {
            messageLabel.text = nil
            timestampLabel.text = nil
        }
    }
    
    func setUnreadMessagesCount(_ unreadMessagesCount: Int?) {
        unreadMessagesCountLabel.isHidden = unreadMessagesCount == nil || 0 == unreadMessagesCount ?? 0
        unreadMessagesCountLabel.text = unreadMessagesCount?.description
    }
    
    func setOnlineStatus(_ status: Bool?) {
        onlineStatusView.isHidden = !(status ?? false)
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
        setupOutgoingLabelAppearance()
        setupMessageLabelAppearance()
        setupUnreadMessagesCountLabelAppearance()
        setupTimestampLabelAppearance()
        
        setupSeparatorAppearance()
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.contentMode = .scaleAspectFill
    }
    
    func setupOnlineStatusViewAppearance() {
        onlineStatusView.backgroundColor = Constants.onlineStatusViewBackgroundColor
        onlineStatusView.layer.borderWidth = Constants.onlineStatusViewBorderWidth
        onlineStatusView.layer.borderColor = Colors.themeColor.cgColor
        onlineStatusView.layer.cornerRadius = Metrics.onlineStatusViewSize / 2
        onlineStatusView.layer.masksToBounds = true
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: Constants.nameLabelFontSize)
        nameLabel.numberOfLines = 1
    }
    
    func setupOutgoingLabelAppearance() {
        outgoingLabel.font = .systemFont(ofSize: Constants.messageLabelFontSize)
        outgoingLabel.text = Constants.outgoingLabelText
        outgoingLabel.isHidden = true
    }
    
    func setupMessageLabelAppearance() {
        messageLabel.font = .systemFont(ofSize: Constants.messageLabelFontSize)
        messageLabel.textColor = .darkGray
        messageLabel.numberOfLines = 1
    }
    
    func setupUnreadMessagesCountLabelAppearance() {
        unreadMessagesCountLabel.textAlignment = .center
        unreadMessagesCountLabel.textColor = .white
        unreadMessagesCountLabel.font = .systemFont(ofSize: Constants.unreadMessagesCountLabelFontSize)
        unreadMessagesCountLabel.layer.masksToBounds = true
        unreadMessagesCountLabel.layer.cornerRadius = Metrics.unreadMessagesCountLabelSize / 2
        unreadMessagesCountLabel.backgroundColor = Colors.themeAdditionalColor
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.font = .systemFont(ofSize: Constants.timestampLabelFontSize)
        timestampLabel.textColor = .darkGray
        timestampLabel.textAlignment = .right
    }
    
    func setupSeparatorAppearance() {
        let leftInset = SharedMetrics.profileImageSize + Metrics.profileImageHorizontalSpace * 2
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
        
        prepareOutgoingLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        profileImageView.addSubview(onlineStatusView)
        
        cellContentView.addSubview(nameLabel)
        cellContentView.addSubview(outgoingLabel)
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
            onlineStatusView.centerXAnchor.constraint(equalTo: profileImageImageView.trailingAnchor,
                                                      constant: -Metrics.onlineStatusViewCenterX),
            onlineStatusView.centerYAnchor.constraint(equalTo: profileImageImageView.bottomAnchor,
                                                      constant: -Metrics.onlineStatusViewCenterX),
            onlineStatusView.widthAnchor.constraint(equalToConstant: Metrics.onlineStatusViewSize),
            onlineStatusView.heightAnchor.constraint(equalToConstant: Metrics.onlineStatusViewSize),
        ])
    }
    
    func setupCellContentViewLayout() {
        cellContentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellContentView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.cellContentTopSpace),
            cellContentView.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Metrics.cellContentRightSpace),
            cellContentView.heightAnchor.constraint(equalToConstant: Metrics.cellContentHeight),
        ])
        
        let cellContentViewBottomConstraint = cellContentView.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: -Metrics.cellContentBottomSpace
        )
        cellContentViewBottomConstraint.priority = UILayoutPriority(LayoutPriority.bottom)
        cellContentViewBottomConstraint.isActive = true
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
            profileImageImageView.heightAnchor.constraint(equalToConstant: SharedMetrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: SharedMetrics.profileImageSize),
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
        ])
        
        messageLabelLeadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor)
        messageLabelLeadingConstraint?.isActive = true
    }
    
    func setupUnreadMessagesCountLabelLayout() {
        unreadMessagesCountLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            unreadMessagesCountLabel.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor),
            unreadMessagesCountLabel.leadingAnchor.constraint(equalTo: messageLabel.trailingAnchor,
                                                              constant: Metrics.unreadMessagesCountLabelLeftSpace),
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
    
    func prepareOutgoingLabelLayout() {
        outgoingLabel.translatesAutoresizingMaskIntoConstraints = false
        outgoingLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        outgoingLabelConstraints.append(contentsOf: [
            outgoingLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.nameMessageSpace),
            outgoingLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            outgoingLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            outgoingLabel.trailingAnchor.constraint(equalTo: messageLabel.leadingAnchor,
                                                    constant: -Metrics.outgoingLabelMessageSpace),
        ])
    }
    
    func showOutgoingLabel() {
        messageLabelLeadingConstraint?.isActive = false
        NSLayoutConstraint.activate(outgoingLabelConstraints)
        
        outgoingLabel.isHidden = false
    }
    
    func hideOutgoingLabel() {
        NSLayoutConstraint.deactivate(outgoingLabelConstraints)
        messageLabelLeadingConstraint?.isActive = true
        
        outgoingLabel.isHidden = true
    }
}
