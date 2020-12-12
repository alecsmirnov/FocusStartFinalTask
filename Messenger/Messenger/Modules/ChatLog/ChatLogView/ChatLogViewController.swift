//
//  ChatLogViewController.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatLogViewController: AnyObject {
    func setTitle(text: String)
    
    func reloadData()
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
}

// MARK: - IChatLogViewController

extension ChatLogViewController: IChatLogViewController {
    func setTitle(text: String) {
        navigationItem.title = text
    }
    
    func reloadData() {
        chatLogView.reloadData()
    }
}

// MARK: - View Setup

private extension ChatLogViewController {
    func setupView() {
        setupViewDelegates()
        setupViewActions()
    }
    
    func setupViewDelegates() {
        chatLogView.collectionViewDataSource = self
        chatLogView.collectionViewDelegate = self
    }
    
    func setupViewActions() {
        chatLogView.sendMessageButtonAction = { [weak self] in
            if let messageText = self?.chatLogView.messageText {
                self?.presenter?.didPressSendButton(messageType: .text(messageText))
                
                self?.chatLogView.clearTextView()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChatLogViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter?.sectionsCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.messagesCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCell.reuseIdentifier,
            for: indexPath
        ) as? MessageCell else { return UICollectionViewCell() }
        
        if let message = presenter?.messageAt(index: indexPath.row) {
            var messageText = ""
            switch message.messageType {
            case .text(let text):
                messageText = text
            }
            
            cell.configure(firstName: "", lastName: "", messageText: messageText)
        }
        
        return cell
    }
}

// MARK: - ICollectionViewDelegate

extension ChatLogViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChatLogViewController: UICollectionViewDelegateFlowLayout {}
