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
        static let cellContentTopSpace: CGFloat = 16
        static let cellContentBottomSpace: CGFloat = 14
        static let cellContentRightSpace: CGFloat = 10
        
        static let profileImageHorizontalSpace: CGFloat = 10
        static let profileImageSize: CGFloat = 54
        
        static let nameMessageSpace: CGFloat = 6
        
        static let nameLabelFontSize: CGFloat = 17
        static let timestampLabelFontSize: CGFloat = 14
        static let messageLabelFontSize: CGFloat = 16
    }
    
    private enum LayoutPriority {
        static let bottom: Float = 750
    }
    
    // MARK: Subviews
    
    private let profileImageView = UIView()
    private let cellContentView = UIView()
    
    private let profileImageImageView = UIImageView()
    private let nameLabel = UILabel()
    private let timestampLabel = UILabel()
    private let messageLabel = UILabel()
    
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
    func configure(withFirstName firstName: String, lastName: String?) {
        nameLabel.text = "\(firstName) \(lastName ?? "")"
    }
    
    func configure(withText text: String) {
        messageLabel.text = text
    }
    
    func setImage(urlString: String) {
        FirebaseStorageService.downloadProfileImageData(urlString: urlString) { data in
            print("here")
            
            if let data = data {
                DispatchQueue.main.async {
                    self.profileImageImageView.image = UIImage(data: data)
                }
            }
        }
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
        setupNameLabelAppearance()
        setupTimestampLabelAppearance()
        setupMessageLabelAppearance()
        
        setupSeparatorAppearance()
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.contentMode = .scaleAspectFill
        profileImageImageView.layer.borderWidth = 1
        profileImageImageView.layer.borderColor = UIColor.systemGray.cgColor
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
        setupNameLabelLayout()
        setupTimestampLabelLayout()
        setupMessageLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        
        cellContentView.addSubview(nameLabel)
        cellContentView.addSubview(timestampLabel)
        cellContentView.addSubview(messageLabel)
    }
    
    func setupProfileImageViewLayout() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.centerYAnchor.constraint(equalTo: cellContentView.centerYAnchor),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
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
