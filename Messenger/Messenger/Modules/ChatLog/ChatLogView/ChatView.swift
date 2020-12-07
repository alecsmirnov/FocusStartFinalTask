//
//  ChatView.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatView: AnyObject {
    var sendMessageButtonAction: Completions.ButtonPress? { get set }

    var messageText: String? { get }
    
    func clearTextView()
    func reloadData()
    //func contentToBottom()
}

final class ChatView: UIView {
    // MARK: Properties
    
    var sendMessageButtonAction: Completions.ButtonPress?
    
    var collectionViewDataSource: UICollectionViewDataSource? {
        get { collectionView.dataSource }
        set { collectionView.dataSource = newValue }
    }
    
    var collectionViewDelegate: UICollectionViewDelegate? {
        get { collectionView.delegate }
        set { collectionView.delegate = newValue }
    }
    
    private enum Settings {
        static let keyboardAnimationDuration = 0.5
    }
    
    private var textContainerViewBottomConstraint: NSLayoutConstraint?
    private var textViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: Subviews
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let textContainerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
        
        //
        textView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - IChatsView

extension ChatView: IChatView {
    var messageText: String? {
        return textView.text
    }
    
    func clearTextView() {
        textView.text = ""
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
//    func contentToBottom() {
//        var numberOfRows = 0
//
//        for section in 0..<tableView.numberOfSections {
//            numberOfRows += tableView.numberOfRows(inSection: section)
//        }
//
//        if 0 < numberOfRows {
//            DispatchQueue.main.async {
//                let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
//
//                UIView.animate(withDuration: 0.4) {
//                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                }
//            }
//        }
//    }
}

// MARK: - Appearance

private extension ChatView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupCollectionViewAppearance()
        
        setupTextContainerViewAppearance()
        setupTextViewAppearance()
        setupSendButtonAppearance()
        
        setupKeyboardObservers()
    }
    
    func setupCollectionViewAppearance() {
        collectionView.backgroundColor = .systemBackground
        
        collectionView.register(MessageCell.self, forCellWithReuseIdentifier: MessageCell.reuseIdentifier)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    func setupTextContainerViewAppearance() {
        textContainerView.backgroundColor = .systemBackground
        textContainerView.sizeToFit()
    }
    
    func setupTextViewAppearance() {
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray3.cgColor
        textView.layer.cornerRadius = 8
        
        textView.font = .systemFont(ofSize: 18)
        textView.isScrollEnabled = false
        
        textView.sizeToFit()
    }
    
    func setupSendButtonAppearance() {
        sendButton.setTitle("Send", for: .normal)
        sendButton.sizeToFit()
        
        sendButton.addTarget(self, action: #selector(didPressSendButton), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension ChatView {
    @objc func didPressSendButton() {
        sendMessageButtonAction?()
    }
}

// MARK: - Layout

private extension ChatView {
    func setupLayout() {
        setupSubviews()
        
        setupCollectionViewLayout()
        
        setupTextContainerViewLayout()
        setupTextViewLayout()
        setupSendButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(collectionView)
        addSubview(textContainerView)
        
        textContainerView.addSubview(textView)
        textContainerView.addSubview(sendButton)
    }
    
    func setupCollectionViewLayout() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func setupTextContainerViewLayout() {
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            textContainerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            textContainerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
        
        textContainerViewBottomConstraint = textContainerView.bottomAnchor.constraint(
            equalTo: safeAreaLayoutGuide.bottomAnchor
        )
        textContainerViewBottomConstraint?.isActive = true
    }
    
    func setupTextViewLayout() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -Metrics.verticalSpace),
            textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor,
                                              constant: Metrics.horizontalSpace),
        ])
        
        textViewTrailingConstraint = textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor,
                                                                        constant: -Metrics.horizontalSpace)
        textViewTrailingConstraint?.isActive = true
    }
    
    func setupSendButtonLayout() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor,
                                               constant: -Metrics.verticalSpace),
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: Metrics.horizontalSpace),
        ])
    }
}

// MARK: - Keyboard Events

private extension ChatView {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardTop = safeAreaInsets.bottom - keyboardSize.cgRectValue.height
        textContainerViewBottomConstraint?.constant = keyboardTop
        
        UIView.animate(withDuration: Settings.keyboardAnimationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textContainerViewBottomConstraint?.constant = 0
        
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate

extension ChatView: UITextViewDelegate {
    // TODO: input check
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            if text.isEmpty {
                textViewTrailingConstraint?.constant = -Metrics.horizontalSpace
                
                UIView.animate(withDuration: Settings.keyboardAnimationDuration) {
                    self.layoutIfNeeded()
                }
            } else if text.count <= 1 {
                textViewTrailingConstraint?.constant = -sendButton.frame.width - Metrics.horizontalSpace * 2
                
                UIView.animate(withDuration: 0.1) {
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
