//
//  SearchView.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import UIKit

protocol ISearchView: AnyObject {
    var noResultLabelIsHidden: Bool { get set }
    var activityIndicatorViewIsHidden: Bool { get set }
    
    var searchText: String? { get }
    
    func reloadData()
}

final class SearchView: UIView {
    // MARK: Properties
    
    var searchBarDelegate: UISearchBarDelegate? {
        get { searchBar.delegate }
        set { searchBar.delegate = newValue }
    }
    
    var tableViewDataSource: UITableViewDataSource? {
        get { tableView.dataSource }
        set { tableView.dataSource = newValue }
    }
    
    var tableViewDelegate: UITableViewDelegate? {
        get { tableView.delegate }
        set { tableView.delegate = newValue }
    }
    
    // MARK: Subviews
    
    private let noResultLabel = UILabel()
    private let activityIndicatorView = UIActivityIndicatorView(style: .medium)
    
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

// MARK: - ISearchView

extension SearchView: ISearchView {
    var noResultLabelIsHidden: Bool {
        get { noResultLabel.isHidden }
        set { noResultLabel.isHidden = newValue }
    }
    
    var activityIndicatorViewIsHidden: Bool {
        get { activityIndicatorView.isHidden }
        set {
            activityIndicatorView.isHidden = newValue
            
            newValue ? activityIndicatorView.stopAnimating() : activityIndicatorView.startAnimating()
        }
    }
    
    var searchText: String? {
        return searchBar.text
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - Appearance

private extension SearchView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupNoResultLabelAppearance()
        setupActivityIndicatorViewAppearance()
        
        setupSearchBarAppearance()
        setupTableViewAppearance()
    }
    
    func setupNoResultLabelAppearance() {
        noResultLabel.text = "No users found"
        noResultLabel.isHidden = true
    }
    
    func setupActivityIndicatorViewAppearance() {
        activityIndicatorView.color = .black
        activityIndicatorView.isHidden = true
    }
    
    func setupSearchBarAppearance() {
        searchBar.searchTextField.autocapitalizationType = .none
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
        setupActivityIndicatorViewLayout()
        
        setupSearchBarLayout()
        setupTableViewLayout()
    }
    
    func setupSubviews() {
        addSubview(noResultLabel)
        addSubview(activityIndicatorView)
        
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
    
    func setupActivityIndicatorViewLayout() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
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
