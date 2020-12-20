//
//  SpinnerView.swift
//  Messenger
//
//  Created by Admin on 10.12.2020.
//

import UIKit

final class SpinnerView: UIView {
    // MARK: Properties
    
    private enum Constants {
        static let viewBackgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        
        static let containerViewBackgroundColor = UIColor.white
        static let containerViewCornerRadius: CGFloat = 8
        
        static let animationDuration: TimeInterval = 0.4
    }
    
    private enum Metrics {
        static let containerViewSize: CGFloat = 60
    }
    
    // MARK: Subviews
    
    private let backgroundView = UIView()
    
    private let containerView = UIView()
    private let activityIndicatorView = UIActivityIndicatorView()
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        
        frame = UIScreen.main.bounds
    }

    // MARK: Initialization
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        
        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods

extension SpinnerView {
    func show() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.alpha = 1
        }
        
        activityIndicatorView.startAnimating()
    }
    
    func hide() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.alpha = 0
        }
        
        activityIndicatorView.stopAnimating()
    }
}

// MARK: - Appearance

private extension SpinnerView {
    func setupAppearance() {
        setupContainerViewAppearance()
        setupActivityIndicatorViewAppearance()
        
        backgroundColor = Constants.viewBackgroundColor
        alpha = 0
    }
    
    func setupContainerViewAppearance() {
        containerView.backgroundColor = Constants.containerViewBackgroundColor
        containerView.layer.cornerRadius = Constants.containerViewCornerRadius
    }
    
    func setupActivityIndicatorViewAppearance() {
        activityIndicatorView.style = .medium
        activityIndicatorView.color = .black
    }
}

// MARK: - Layout

private extension SpinnerView {
    func setupLayout() {
        addSubviews()
        
        setupContainerViewLayout()
        setupActivityIndicatorViewLayout()
    }
    
    func addSubviews() {
        addSubview(containerView)
        
        containerView.addSubview(activityIndicatorView)
    }
    
    func setupContainerViewLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Metrics.containerViewSize),
            containerView.widthAnchor.constraint(equalToConstant: Metrics.containerViewSize),
        ])
    }
    
    func setupActivityIndicatorViewLayout() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
    }
}
