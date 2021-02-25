//
//  SearchView.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import UIKit

final class SearchView: UIView {
    // MARK: Properties
    
    var searchBarDelegate: UISearchBarDelegate? {
        get {
            return searchBar.delegate
        }
        set {
            searchBar.delegate = newValue
        }
    }
    
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
        static let tableViewReloadAnimationDuration = 0.3
        
        static let noResultLabelShowAnimationDuration = 0.6
        static let noResultLabelHideAnimationDuration = 0.1
    }
    
    // MARK: Subviews
    
    private let noResultLabel = UILabel()
    private let spinnerView = SpinnerView()
    
    private let searchBar = UISearchBar()
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

extension SearchView {
    var searchText: String? {
        return searchBar.text
    }
    
    func reloadData() {
        UIView.transition(
            with: tableView,
            duration: Constants.tableViewReloadAnimationDuration,
            options: [.transitionCrossDissolve]) {
            self.tableView.reloadData()
        }
    }
    
    func showNoResultLabel() {
        UIView.animate(withDuration: Constants.noResultLabelShowAnimationDuration) {
            self.noResultLabel.alpha = 1
        }
    }
    
    func hideNoResultLabel() {
        UIView.animate(withDuration: Constants.noResultLabelHideAnimationDuration) {
            self.noResultLabel.alpha = 0
        }
    }
    
    func showSpinnerView() {
        spinnerView.show()
    }
    
    func hideSpinnerView() {
        spinnerView.hide()
    }
}

// MARK: - Appearance

private extension SearchView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupNoResultLabelAppearance()
        
        setupSearchBarAppearance()
        setupTableViewAppearance()
    }
    
    func setupNoResultLabelAppearance() {
        noResultLabel.text = "No users found"
        noResultLabel.alpha = 0
    }
    
    func setupSearchBarAppearance() {
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.placeholder = "Enter user name"
        searchBar.becomeFirstResponder()
    }
    
    func setupTableViewAppearance() {
        tableView.tableFooterView = UIView()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
    }
}

// MARK: - Layout

private extension SearchView {
    func setupLayout() {
        setupSubviews()
        
        setupNoResultLabelLayout()
        
        setupSearchBarLayout()
        setupTableViewLayout()
    }
    
    func setupSubviews() {
        addSubview(noResultLabel)
        addSubview(spinnerView)
        
        addSubview(searchBar)
        insertSubview(tableView, belowSubview: noResultLabel)
    }
    
    func setupNoResultLabelLayout() {
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            noResultLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            noResultLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
        ])
    }
    
    func setupSearchBarLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func setupTableViewLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}
