//
//  ChatsViewController.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

protocol IChatsViewController: AnyObject {
    var activityIndicator: Bool { get set }
    
    func reloadData()
}

final class ChatsViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IChatsPresenter?
    
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
        
        setupViewDelegates()
        setupButtons()
    }
}

// MARK: - IChatsViewController

extension ChatsViewController: IChatsViewController {
    var activityIndicator: Bool {
        get { chatsView.activityIndicator }
        set {
            chatsView.activityIndicator = newValue
            
            navigationController?.setNavigationBarHidden(newValue, animated: true)
        }
    }
    
    func reloadData() {
        chatsView.reloadData()
    }
}

// MARK: - Buttons

private extension ChatsViewController {
    func setupButtons() {
        setupSearchButton()
        setupMenuButton()
    }
    
    func setupSearchButton() {
        let searchBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.pencil"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(didPressSearchButton))
        
        navigationItem.rightBarButtonItem = searchBarButtonItem
    }
    
    func setupMenuButton() {
        let menuBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"),
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

// MARK: - View Delegates

private extension ChatsViewController {
    func setupViewDelegates() {
        chatsView.tableViewDataSource = self
        chatsView.tableViewDelegate = self
    }
}

// MARK: - UITableViewDataSource

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.chatsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseIdentifier,
                                                       for: indexPath) as? ChatCell else { return UITableViewCell() }
        
        if let chat = presenter?.chat(forRowAt: indexPath.row) {
            var messageText = ""
            
            switch chat.latestMessage?.type {
            case .text(let text):
                messageText = text
            case .none: break
            }
            
            if let companion = chat.companion {
                cell.configure(withFirstName: companion.firstName, lastName: companion.lastName)
                cell.configure(withText: messageText)
                
                cell.setUnreadMessagesCount(chat.unreadMessagesCount ?? 0)
                
//                if let urlString = companion.profilePhotoURL {
//                    cell.setImage(urlString: urlString)
//                }
            }
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        presenter?.didSelectChatAt(index: indexPath.row)
    }
}
