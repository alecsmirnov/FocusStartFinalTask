//
//  ChatLogView.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatLogView: AnyObject {
    var sendMessageButtonAction: Completions.ButtonPress? { get set }

    var messageText: String? { get }
    
    func clearTextView()
    func reloadData()
    func updateRowAt(index: Int)
    func insertNewRow()
    func startFromRowAt(index: Int)
    func scrollToBottom()
    
    // test
    func viewDidLoad()
}

final class ChatLogView: UIView {
    // MARK: Properties
    
    var sendMessageButtonAction: Completions.ButtonPress?
    
    var tableViewDataSource: UITableViewDataSource? {
        get { tableView.dataSource }
        set { tableView.dataSource = newValue }
    }
    
    var tableViewDelegate: UITableViewDelegate? {
        get { tableView.delegate }
        set { tableView.delegate = newValue }
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
    }
    
    private enum Settings {
        static let keyboardAnimationDuration = 0.5
    }
    
    private var textContainerViewBottomConstraint: NSLayoutConstraint?
    private var textViewTrailingConstraint: NSLayoutConstraint?
    
    // MARK: Subviews
    
    let tableView = UITableView()
    
    // TODO: rename - inputContainer
    private let textContainerView = UIView()
    // TODO: rename - inputTextView
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    
    // MARK: Lifecycle
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        //updateFlowLayout()
    }
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
        setupViewDelegates()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardObservers()
    }
}

// MARK: - IChatLogView

extension ChatLogView: IChatLogView {
    var messageText: String? {
        return textView.text
    }
    
    func clearTextView() {
        textView.text = nil
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateRowAt(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func insertNewRow() {
        //let lastRowIndex = tableView.numberOfRows(inSection: 0)
        //let lastRowIndexPath = IndexPath(row: lastRowIndex, section: 0)
        
        //tableView.insertRows(at: [lastRowIndexPath], with: .none)
        
        
        
        
        // test
        let firstRowIndexPath = IndexPath(row: 0, section: 0)
        
        tableView.insertRows(at: [firstRowIndexPath], with: .automatic)
    }
    
    func startFromRowAt(index: Int) {
        let lastRowIndex = tableView.numberOfRows(inSection: 0) - 1
        
        if 1 < lastRowIndex {
            var currentRowIndex = lastRowIndex
            
            if index < lastRowIndex {
                currentRowIndex -= index
            }
            
            let indexPath = IndexPath(row: currentRowIndex, section: 0)
            
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    func viewDidLoad() {
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    // TODO: fix
    func scrollToBottom() {
//        let sectionsCount = tableView.numberOfSections
//
//        if 0 < sectionsCount {
//            let itemsCount = tableView.numberOfItems(inSection: sectionsCount - 1)
//
//            if 0 < itemsCount {
//                let indexPath = IndexPath(item: itemsCount - 1, section: sectionsCount - 1)
//
//                DispatchQueue.main.async {
//                    self.tableView.scrollToItem(at: indexPath, at: .bottom, animated: true)
//                }
//            }
//        }
    }
}

// MARK: - Appearance

private extension ChatLogView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupTableViewAppearance()
        
        setupTextContainerViewAppearance()
        setupTextViewAppearance()
        setupSendButtonAppearance()
    }
    
    func setupTableViewAppearance() {
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
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

private extension ChatLogView {
    @objc func didPressSendButton() {
        sendMessageButtonAction?()
    }
}

// MARK: - Layout

private extension ChatLogView {
    func setupLayout() {
        setupSubviews()
        
        setupTableViewLayout()
        
        setupTextContainerViewLayout()
        setupTextViewLayout()
        setupSendButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(tableView)
        addSubview(textContainerView)
        
        textContainerView.addSubview(textView)
        textContainerView.addSubview(sendButton)
    }
    
    func setupTableViewLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
        
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func setupTextContainerViewLayout() {
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
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

// MARK: - Flow Layout

private extension ChatLogView {
//    func updateFlowLayout() {
//        if let collectionViewFlowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            collectionViewFlowLayout.estimatedItemSize = CGSize(width: UIScreen.main.bounds.size.width, height: .zero)
//        }
//    }
}

// MARK: - Keyboard Events

private extension ChatLogView {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
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

// MARK: - View Delegates

private extension ChatLogView {
    func setupViewDelegates() {
        textView.delegate = self
    }
}

// MARK: - UITextViewDelegate

extension ChatLogView: UITextViewDelegate {
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
