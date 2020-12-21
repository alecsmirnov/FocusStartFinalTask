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
    func updateMessageAt(section: Int, row: Int)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("appear")
        
        presenter?.viewDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("diss")
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
    
    func updateMessageAt(section: Int, row: Int) {
        chatLogView.updateRowAt(row: row, section: section)
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return ChatLogSectionView(dateString: presenter?.sectionDate(section: section))
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter?.sectionsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.messagesCount(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.reuseIdentifier,
                                                       for: indexPath) as? MessageCell else {
            return UITableViewCell()
        }
        
        if let message = presenter?.messageAt(section: indexPath.section, index: indexPath.row) {
            cell.configure(with: message)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatLogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if tableView.visibleCells.contains(cell) {
                self.presenter?.didReadMessageAt(section: indexPath.section, index: indexPath.row)
            }
        }
    }
}
