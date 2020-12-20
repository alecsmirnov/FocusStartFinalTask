//
//  MenuOptionCell.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

final class MenuOptionCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = String(describing: self)
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
        
        static let iconImageLeadingSpace: CGFloat = 30
        static let iconImageViewSize: CGFloat = 24
    }
    
    // MARK: Subviews
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let descriptionLabel = UILabel()
    
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

extension MenuOptionCell {
    func configure(with description: String, and icon: UIImage?) {
        descriptionLabel.text = description
        iconImageView.image = icon
    }
}

// MARK: - Appearance

private extension MenuOptionCell {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupIconImageViewAppearance()
        setupDescriptionLabelAppearance()
    }
    
    func setupIconImageViewAppearance() {
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.tintColor = .black
    }
    
    func setupDescriptionLabelAppearance() {
        descriptionLabel.text = "sample text"
    }
}

// MARK: - Layout

private extension MenuOptionCell {
    func setupLayout() {
        setupSubviews()
        
        setupContainerViewLayout()
        setupIconImageViewLayout()
        setupDescriptionLabelLayout()
    }
    
    func setupSubviews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(descriptionLabel)
    }
    
    func setupContainerViewLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    func setupIconImageViewLayout() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                   constant: Metrics.iconImageLeadingSpace),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: Metrics.iconImageViewSize),
            iconImageView.heightAnchor.constraint(equalToConstant: Metrics.iconImageViewSize),
        ])
    }
    
    func setupDescriptionLabelLayout() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            descriptionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor,
                                                      constant: Metrics.horizontalSpace),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                       constant: -Metrics.horizontalSpace),
        ])
    }
}
