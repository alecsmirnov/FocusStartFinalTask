//
//  ChatsView.swift
//  Messenger
//
//  Created by Admin on 25.11.2020.
//

import UIKit

final class ChatsView: UIView {
    // MARK: Properties
    
    var tableViewDataSource: UITableViewDataSource? {
        get {
            return tableView.dataSource
        }
        set {
            tableView.dataSource = newValue
        }
    }
    
    var tableViewDelegate: UITableViewDelegate? {
        get {
            return tableView.delegate
        }
        set {
            tableView.delegate = newValue
        }
    }
    
    private enum Constants {
        static let tableViewReloadAnimationDuration = 0.2
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

// MARK: - Public Methods

extension ChatsView {
    func insertNewRow() {
        let sectionsCount = tableView.numberOfSections
        
        if 0 < sectionsCount {
            let section = 0
            
            let lastRowIndex = tableView.numberOfRows(inSection: section)
            let lastRowIndexPath = IndexPath(row: lastRowIndex, section: section)
            
            tableView.insertRows(at: [lastRowIndexPath], with: .bottom)
        } else {
            reloadData()
        }
    }
    
    func updateRow(at index: Int) {
        let section = 0
        let indexPath = IndexPath(row: index, section: section)
        
        UIView.transition(
            with: tableView,
            duration: Constants.tableViewReloadAnimationDuration,
            options: [.transitionCrossDissolve]) {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func reloadData() {
        UIView.transition(
            with: tableView,
            duration: Constants.tableViewReloadAnimationDuration,
            options: [.transitionCrossDissolve]) {
            self.tableView.reloadData()
        }
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
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
}
