//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

protocol IChatsViewController: AnyObject {
    func insertNewRow()
    func updateRow(at index: Int)
    func reloadData()
}

final class ChatsViewController: MyNavigationBarViewController {
    // MARK: Properties
    
    var presenter: IChatsPresenter?
    
    private enum Constants {
        static let searchButtonImage = UIImage(systemName: "square.and.pencil")
        static let menuButtonImage = UIImage(systemName: "line.horizontal.3")
        
        static let clearMenuTitle = "Clear history"
        static let removeMenuTitle = "Remove"
    }
    
    private var chatsView: ChatsView {
        guard let view = view as? ChatsView else {
            fatalError("view is not a ChatsView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = ChatsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        setupView()
        setupButtons()
    }
}

// MARK: - IChatsViewController

extension ChatsViewController: IChatsViewController {
    func insertNewRow() {
        chatsView.insertNewRow()
    }
    
    func updateRow(at index: Int) {
        chatsView.updateRow(at: index)
    }
    
    func reloadData() {
        chatsView.reloadData()
    }
}

// MARK: - Private Methods

private extension ChatsViewController {
    func setupView() {
        chatsView.tableViewDataSource = self
        chatsView.tableViewDelegate = self
    }
}

// MARK: - Buttons

private extension ChatsViewController {
    func setupButtons() {
        setupSearchButton()
        setupMenuButton()
    }
    
    func setupSearchButton() {
        let searchBarButtonItem = UIBarButtonItem(image: Constants.searchButtonImage,
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(didPressSearchButton))
        
        navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    func setupMenuButton() {
        let menuBarButtonItem = UIBarButtonItem(image: Constants.menuButtonImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(didPressMenuButton))
        
        navigationItem.leftBarButtonItem = menuBarButtonItem
    }
}

// MARK: - Actions

private extension ChatsViewController {
    @objc func didPressSearchButton() {
        presenter?.didPressSearchButton()
    }
    
    @objc func didPressMenuButton() {
        presenter?.didPressMenuButton()
    }
}

// MARK: - UITableViewDataSource

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.chatsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseIdentifier,
                                                       for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }
        
        if let chat = presenter?.chat(at: indexPath.row) {
            cell.configure(with: chat)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presenter?.didSelectChat(at: indexPath.row)
    }
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let clear = UIContextualAction(style: .normal,
                                       title: Constants.clearMenuTitle) { [weak self] _, _, completionHandler in
            self?.presenter?.didClearChat(at: indexPath.row)
            
            completionHandler(true)
        }
        
        let remove = UIContextualAction(style: .destructive,
                                        title: Constants.removeMenuTitle) { [weak self] _, _, completionHandler in
            self?.presenter?.didRemoveChat(at: indexPath.row)
            
            completionHandler(true)
        }
        
        remove.backgroundColor = Colors.themeAdditionalColor

        return UISwipeActionsConfiguration(actions: [remove, clear])
    }
}
