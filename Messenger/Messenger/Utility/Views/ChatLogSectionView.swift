//
//  ChatLogSectionView.swift
//  Messenger
//
//  Created by Admin on 20.12.2020.
//

import UIKit

final class ChatLogSectionView: UIView {
    // MARK: Subviews
    
    private let timestampLabel = DateSectionLabel()
    
    // MARK: Initialization
    
    init(dateString: String?) {
        timestampLabel.text = dateString
        
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Appearance

private extension ChatLogSectionView {
    func setupAppearance() {
        setupTimestampLabelAppearance()
    }
    
    func setupTimestampLabelAppearance() {
        timestampLabel.textColor = .white
        timestampLabel.textAlignment = .center
        timestampLabel.backgroundColor = .lightGray
        timestampLabel.layer.cornerRadius = timestampLabel.frame.size.width / 2
    }
}

// MARK: - Appearance

private extension ChatLogSectionView {
    func setupLayout() {
        setupSubviews()
        setupTimestampLabelLayout()
    }
    
    func setupSubviews() {
        addSubview(timestampLabel)
    }
    
    func setupTimestampLabelLayout() {
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timestampLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timestampLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

// MARK: - DateSectionLabel

fileprivate final class DateSectionLabel: UILabel {
    // MARK: Properties
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
    }

    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)
        
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Appearance

private extension DateSectionLabel {
    func setupAppearance() {
        layer.masksToBounds = true
    }
}

extension DateSectionLabel {
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        
        let height = originalContentSize.height + Metrics.verticalSpace
        let width = originalContentSize.width + Metrics.horizontalSpace
        
        layer.cornerRadius = height / 2
        
        let contentSize = CGSize(width: width, height: height)
        
        return contentSize
    }
}
