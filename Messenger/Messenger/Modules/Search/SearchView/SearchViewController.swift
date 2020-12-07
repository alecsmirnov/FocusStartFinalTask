//
//  SearchViewController.swift
//  Messenger
//
//  Created by Admin on 27.11.2020.
//

import UIKit

protocol ISearchViewController: AnyObject {
    var noResultLabelIsHidden: Bool { get set }
    var activityIndicatorViewIsHidden: Bool { get set }
    
    func reloadData()
}

final class SearchViewController: UIViewController {
    // MARK: Properties
    
    var presenter: ISearchPresenter?
    
    private enum Settings {
        static let searchBarDelay = 0.8
    }
    
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
        
        setupViewDelegates()
    }
}

// MARK: - ISearchViewController

extension SearchViewController: ISearchViewController {
    var noResultLabelIsHidden: Bool {
        get { searchView.noResultLabelIsHidden }
        set { searchView.noResultLabelIsHidden = newValue }
    }
    
    var activityIndicatorViewIsHidden: Bool {
        get { searchView.activityIndicatorViewIsHidden }
        set { searchView.activityIndicatorViewIsHidden = newValue }
    }
    
    func reloadData() {
        searchView.reloadData()
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

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(didStartTyping), object: searchBar)
        
        perform(#selector(didStartTyping), with: searchBar, afterDelay: Settings.searchBarDelay)
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
        return presenter?.companionsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatsCell.reuseIdentifier,
                                                       for: indexPath) as? ChatsCell else {
            return UITableViewCell()
        }
        
        if let companion = presenter?.companion(forRowAt: indexPath.row) {
            cell.configure(with: companion)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectCompanionAt(index: indexPath.row)
    }
}
