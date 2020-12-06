//
//  ChatsCell.swift
//  Messenger
//
//  Created by Admin on 25.11.2020.
//

import UIKit

protocol IChatsCell: AnyObject {}

final class ChatsCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Constants {
        static let defaultImageName = "person.crop.circle"
    }
    
    private enum Metrics {
        static let cellContentTopSpace: CGFloat = 16
        static let cellContentBottomSpace: CGFloat = 14
        static let cellContentRightSpace: CGFloat = 10
        
        static let profilePhotoHorizontalSpace: CGFloat = 10
        
        static let profilePhotoHeight: CGFloat = 54
        static let profilePhotoWidth: CGFloat = 54
        
        static let nameMessageSpace: CGFloat = 6
        
        static let nameLabelFontSize: CGFloat = 17
        static let timestampLabelFontSize: CGFloat = 14
        static let messageLabelFontSize: CGFloat = 16
    }
    
    private enum LayoutPriority {
        static let bottom: Float = 750
    }
    
    // MARK: Subviews
    
    private let profilePhotoView = UIView()
    private let cellContentView = UIView()
    
    private let profilePhotoImageView = UIImageView()
    private let nameLabel = UILabel()
    private let timestampLabel = UILabel()
    private let messageLabel = UILabel()
    
    // MARK: Lifecycle
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawProfilePhotoImageView()
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

// MARK: - IChatsCell

extension ChatsCell: IChatsCell {}

// MARK: - Public Methods

extension ChatsCell {    
    func configure(with companion: SearchCompanion) {
        nameLabel.text = "\(companion.firstName) \(companion.lastName ?? "")"
        
        if let storedDate = companion.chat?.latestMessages.date,
           let date = DateConverter.stringToDate(storedDate) {
            timestampLabel.text = DateConverter.dateToChatLatestMessageString(date)
        }
        
        if companion.profilePhotoURL == nil {
            profilePhotoImageView.image = UIImage(systemName: Constants.defaultImageName)
        }
    }
    
    func configure(withFirstName firstName: String, lastName: String?) {
        nameLabel.text = "\(firstName) \(lastName ?? "")"
    }
}

// MARK: - Draw

private extension ChatsCell {
    func drawProfilePhotoImageView() {
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.height / 2
        profilePhotoImageView.clipsToBounds = true
    }
}

// MARK: - Appearance

private extension ChatsCell {
    func setupAppearance() {
        setupProfilePhotoImageViewAppearance()
        setupNameLabelAppearance()
        setupTimestampLabelAppearance()
        setupMessageLabelAppearance()
        
        setupSeparatorAppearance()
    }
    
    func setupProfilePhotoImageViewAppearance() {
        profilePhotoImageView.contentMode = .scaleAspectFill
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: Metrics.nameLabelFontSize)
        nameLabel.numberOfLines = 1
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.font = .systemFont(ofSize: Metrics.timestampLabelFontSize)
        timestampLabel.textAlignment = .right
        timestampLabel.numberOfLines = 1
    }
    
    func setupMessageLabelAppearance() {
        messageLabel.font = .systemFont(ofSize: Metrics.messageLabelFontSize)
        messageLabel.numberOfLines = 1
    }
    
    func setupSeparatorAppearance() {
        let leftInset = Metrics.profilePhotoWidth + Metrics.profilePhotoHorizontalSpace * 2
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
    }
}

// MARK: - Layout

private extension ChatsCell {
    func setupLayout() {
        setupSubviews()
        
        setupProfilePhotoViewLayout()
        setupCellContentViewLayout()
        
        setupProfilePhotoImageViewLayout()
        setupNameLabelLayout()
        setupTimestampLabelLayout()
        setupMessageLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profilePhotoView)
        contentView.addSubview(cellContentView)
        
        profilePhotoView.addSubview(profilePhotoImageView)
        
        cellContentView.addSubview(nameLabel)
        cellContentView.addSubview(timestampLabel)
        cellContentView.addSubview(messageLabel)
    }
    
    func setupProfilePhotoViewLayout() {
        profilePhotoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePhotoView.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            profilePhotoView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
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
            cellContentView.leadingAnchor.constraint(equalTo: profilePhotoView.trailingAnchor),
            cellContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -Metrics.cellContentRightSpace),
        ])
    }
    
    func setupProfilePhotoImageViewLayout() {
        profilePhotoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profilePhotoImageView.topAnchor.constraint(equalTo: profilePhotoView.topAnchor),
            profilePhotoImageView.bottomAnchor.constraint(equalTo: profilePhotoView.bottomAnchor),
            profilePhotoImageView.leadingAnchor.constraint(equalTo: profilePhotoView.leadingAnchor,
                                                           constant: Metrics.profilePhotoHorizontalSpace),
            profilePhotoImageView.trailingAnchor.constraint(equalTo: profilePhotoView.trailingAnchor,
                                                            constant: -Metrics.profilePhotoHorizontalSpace),
            profilePhotoImageView.heightAnchor.constraint(equalToConstant: Metrics.profilePhotoHeight),
            profilePhotoImageView.widthAnchor.constraint(equalToConstant: Metrics.profilePhotoWidth),
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
    
    func setupTimestampLabelLayout() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            timestampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            timestampLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
        ])
    }
    
    func setupMessageLabelLayout() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.nameMessageSpace),
            messageLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
        ])
    }
}
