//
//  SearchViewController.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import UIKit

protocol ISearchViewController: AnyObject {
    func reloadData()
    
    func showNoResultLabel()
    func hideNoResultLabel()
    
    func showSpinnerView()
    func hideSpinnerView()
}

final class SearchViewController: UIViewController {
    // MARK: Properties
    
    var presenter: ISearchPresenter?
    
    private var searchView: SearchView {
        guard let view = view as? SearchView else {
            fatalError("view is not a SearchView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = SearchView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        setupButtons()
        setupViewDelegates()
    }
}

// MARK: - ISearchViewController

extension SearchViewController: ISearchViewController {
    func reloadData() {
        searchView.reloadData()
    }
    
    func showNoResultLabel() {
        searchView.showNoResultLabel()
    }
    
    func hideNoResultLabel() {
        searchView.hideNoResultLabel()
    }
    
    func showSpinnerView() {
        searchView.showSpinnerView()
    }
    
    func hideSpinnerView() {
        searchView.hideSpinnerView()
    }
}

// MARK: - View Delegates

private extension SearchViewController {
    func setupViewDelegates() {
        searchView.searchBarDelegate = self
        searchView.tableViewDataSource = self
        searchView.tableViewDelegate = self
    }
}

// MARK: - Buttons

private extension SearchViewController {
    func setupButtons() {
        setupCloseButton()
    }
    
    func setupCloseButton() {
        let menuBarButtonItem = UIBarButtonItem(title: "Close",
                                                style: .plain,
                                                target: self,
                                                action: #selector(didPressCloseButton))
        
        navigationItem.leftBarButtonItem = menuBarButtonItem
    }
}

// MARK: - Actions

private extension SearchViewController {
    @objc func didPressCloseButton() {
        presenter?.didPressCloseButton()
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchView.searchText {
            presenter?.didChangeText(text)
        }
    }

    @objc func didStartTyping() {
        if let text = searchView.searchText {
            presenter?.didChangeText(text)
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.usersCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier,
                                                       for: indexPath) as? UserCell else { return UITableViewCell() }
        
        if let user = presenter?.user(forRowAt: indexPath.row) {
            cell.configure(with: user)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectUserAt(index: indexPath.row)
    }
}
