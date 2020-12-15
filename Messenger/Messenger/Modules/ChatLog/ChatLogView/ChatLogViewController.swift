//
//  ChatLogViewController.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatLogViewController: AnyObject {
    func setTitle(text: String)
    
    func endRefreshing()
    
    func reloadData()
    func updateRowAt(index: Int)
    func insertNewRow()
    func startFromRowAt(index: Int)
    func scrollToBottom()
}

final class ChatLogViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IChatLogPresenter?
    
    private var chatLogView: ChatLogView {
        guard let view = view as? ChatLogView else {
            fatalError("view is not a ChatLogView instance")
        }
        
        return view
    }
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = ChatLogView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        setupView()           
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter?.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        presenter?.viewDidAppear()
    }
}

// MARK: - IChatLogViewController

extension ChatLogViewController: IChatLogViewController {
    func setTitle(text: String) {
        navigationItem.title = text
    }
    
    func endRefreshing() {
        chatLogView.endRefreshing()
    }
    
    func reloadData() {
        chatLogView.reloadData()
    }
    
    func updateRowAt(index: Int) {
        chatLogView.updateRowAt(index: index)
    }
    
    func insertNewRow() {
        chatLogView.insertNewRow()
    }
    
    func startFromRowAt(index: Int) {
        chatLogView.startFromRowAt(index: index)
    }
    
    func scrollToBottom() {
        chatLogView.scrollToBottom()
    }
}

// MARK: - View Setup

private extension ChatLogViewController {
    func setupView() {
        setupViewDelegates()
        setupViewActions()
    }
    
    func setupViewDelegates() {
        chatLogView.tableViewDataSource = self
        chatLogView.tableViewDelegate = self
    }
    
    func setupViewActions() {
        chatLogView.sendMessageButtonAction = { [weak self] in
            if let messageText = self?.chatLogView.messageText {
                self?.presenter?.didPressSendButton(messageType: .text(messageText))
                
                self?.chatLogView.clearTextView()
            }
        }
        
        chatLogView.pullToRefreshAction = { [weak self] in
            self?.presenter?.didPullToRefresh()
        }
    }
}

// MARK: - UITableViewDataSource

extension ChatLogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.messagesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier,
                                                       for: indexPath) as? MessageCell else { return UITableViewCell() }
        
        
        if let message = presenter?.messageAt(index: indexPath.row) {
            var messageText = ""
            switch message.type {
            case .text(let text):
                messageText = text
            }
            
            cell.configure(firstName: "Empty", lastName: "", messageText: messageText, isRead: message.isRead)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if tableView.visibleCells.contains(cell) {
                self.presenter?.didReadMessageAt(index: indexPath.row)
            }
        }
    }
}
