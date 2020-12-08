//
//  ChatsView.swift
//  Messenger
//
//  Created by Admin on 25.11.2020.
//

import UIKit

protocol IChatsView: AnyObject {
    var activityIndicator: Bool { get set }
    
    func reloadData()
}

final class ChatsView: UIView {
    // MARK: Properties
    
    var tableViewDataSource: UITableViewDataSource? {
        get { tableView.dataSource }
        set { tableView.dataSource = newValue }
    }
    
    var tableViewDelegate: UITableViewDelegate? {
        get { tableView.delegate }
        set { tableView.delegate = newValue }
    }
    
    // MARK: Subviews
    
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let tableView = UITableView()
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - IChatsView

extension ChatsView: IChatsView {
    var activityIndicator: Bool {
        get { activityIndicatorView.isAnimating }
        set {
            tableView.isHidden = newValue
            
            newValue ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Appearance

private extension ChatsView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupActivityIndicatorViewAppearance()
        setupTableViewAppearance()
    }
    
    func setupActivityIndicatorViewAppearance() {
        activityIndicatorView.color = .black
    }
    
    func setupTableViewAppearance() {
        tableView.tableFooterView = UIView()
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseIdentifier)
    }
}

// MARK: - Layout

private extension ChatsView {
    func setupLayout() {
        setupSubviews()
        
        setupActivityIndicatorViewLayout()
        setupTableViewLayout()
    }
    
    func setupSubviews() {
        addSubview(activityIndicatorView)
        addSubview(tableView)
    }
    
    func setupActivityIndicatorViewLayout() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    func setupTableViewLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
