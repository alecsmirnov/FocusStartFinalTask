//
//  ChatViewController.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatViewController: AnyObject {}

final class ChatViewController: UIViewController {
    // MARK: Properties
    
    var presenter: IChatPresenter?
    
    private var chatView: ChatView {
        guard let view = view as? ChatView else {
            fatalError("view is not a ChatView instance")
        }
        
        return view
    }
    
    private var companion: SearchCompanion?
    
    // MARK: Lifecycle
    
    override func loadView() {
        view = ChatView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewDelegates()
        
        navigationItem.title = "\(companion?.firstName ?? "") \(companion?.lastName ?? "")"
        
        chatView.sendMessageButtonAction = { [weak self] in
            let messageText = self?.chatView.messageText ?? ""
            print("MessageText: \(messageText)")
            
           
            let senderIdentifier = "-MNbOYOze_H92y0n0QtG"
            let receiverIdentifier = "-MNbOYP-8hYJs-uAqOTp"
            
            self?.chatView.clearTextView()
            
            if let _ = self?.companion {
                let message = FirebaseMessage(senderIdentifier: senderIdentifier,
                                              messageType: .text(messageText),
                                              date: "today", isRead: false)
                
                FirebaseDatabaseService.send(message: message,
                                             to: receiverIdentifier) { error in
                    
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //
    func randomString() -> String {
        let letters = "0123456789"
        return String((0..<15).map { _ in letters.randomElement()! })
    }
}

// MARK: - IChatViewController

extension ChatViewController: IChatViewController {}

// MARK: - Public Methods

extension ChatViewController {
    func setCompanion(_ item: SearchCompanion) {
        companion = item
    }
}

// MARK: - View Delegates

private extension ChatViewController {
    func setupViewDelegates() {
        chatView.collectionViewDataSource = self
        chatView.collectionViewDelegate = self
    }
}

// MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter?.sectionsCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.messagesCount ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCell.reuseIdentifier,
            for: indexPath
        ) as? MessageCell else { return UICollectionViewCell() }
        
        return cell
    }
}

// MARK: - ICollectionViewDelegate

extension ChatViewController: UICollectionViewDelegate {}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChatViewController: UICollectionViewDelegateFlowLayout {}
