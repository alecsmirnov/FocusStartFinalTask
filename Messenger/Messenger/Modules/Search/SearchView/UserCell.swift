//
//  UserCell.swift
//  Messenger
//
//  Created by Admin on 08.12.2020.
//

import UIKit

protocol IUserCell: AnyObject {}

final class UserCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Metrics {
        static let cellContentTopSpace: CGFloat = 16
        static let cellContentBottomSpace: CGFloat = 14
        static let cellContentRightSpace: CGFloat = 10
        
        static let profileImageHorizontalSpace: CGFloat = 10
        
        static let profileImageHeight: CGFloat = 54
        static let profileImageWidth: CGFloat = 54
        
        static let nameEmailVerticalSpace: CGFloat = 6
        
        static let nameLabelFontSize: CGFloat = 17
        static let emailLabelFontSize: CGFloat = 16
    }
    
    private enum LayoutPriority {
        static let bottom: Float = 750
    }
    
    // MARK: Subviews
    
    private let profileImageView = UIView()
    private let cellContentView = UIView()
    
    private let profileImageImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
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

// MARK: - IUserCell

extension UserCell: IUserCell {}

// MARK: - Public Methods

extension UserCell {
    func configure(with user: UserData) {
        nameLabel.text = "\(user.firstName) \(user.lastName ?? "")"
        emailLabel.text = user.email
    }
}

// MARK: - Draw

private extension UserCell {
    func drawProfileImageImageView() {
        profileImageImageView.layer.cornerRadius = profileImageImageView.frame.size.height / 2
        profileImageImageView.clipsToBounds = true
    }
}

// MARK: - Appearance

private extension UserCell {
    func setupAppearance() {
        setupProfileImageImageViewAppearance()
        setupNameLabelAppearance()
        setupEmailLabelAppearance()
        
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
    
    func setupEmailLabelAppearance() {
        emailLabel.font = .systemFont(ofSize: Metrics.emailLabelFontSize)
        emailLabel.numberOfLines = 1
        emailLabel.textColor = .darkGray
    }
    
    func setupSeparatorAppearance() {
        let leftInset = Metrics.profileImageWidth + Metrics.profileImageHorizontalSpace * 2
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
    }
}

// MARK: - Layout

private extension UserCell {
    func setupLayout() {
        setupSubviews()
        
        setupProfileImageViewLayout()
        setupCellContentViewLayout()
        
        setupProfilePhotoImageViewLayout()
        setupNameLabelLayout()
        setupEmailLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(cellContentView)
        
        profileImageView.addSubview(profileImageImageView)
        
        cellContentView.addSubview(nameLabel)
        cellContentView.addSubview(emailLabel)
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
    
    func setupProfilePhotoImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            profileImageImageView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            profileImageImageView.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor,
                                                           constant: Metrics.profileImageHorizontalSpace),
            profileImageImageView.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor,
                                                            constant: -Metrics.profileImageHorizontalSpace),
            profileImageImageView.heightAnchor.constraint(equalToConstant: Metrics.profileImageHeight),
            profileImageImageView.widthAnchor.constraint(equalToConstant: Metrics.profileImageWidth),
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
    
    func setupEmailLabelLayout() {
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.nameEmailVerticalSpace),
            emailLabel.bottomAnchor.constraint(equalTo: cellContentView.bottomAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: cellContentView.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: cellContentView.trailingAnchor),
        ])
    }
}
