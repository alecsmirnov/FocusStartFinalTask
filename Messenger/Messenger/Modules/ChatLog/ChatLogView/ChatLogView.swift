//
//  ChatLogView.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol IChatLogView: AnyObject {
    var sendMessageButtonAction: Completions.ButtonPress? { get set }
    var pullToRefreshAction: Completions.ButtonPress? { get set }

    var messageText: String? { get }
    
    func endRefreshing()
    
    func clearTextView()
    func reloadData()
    
    func insertNewRow()
    func updateRowAt(row: Int, section: Int)
    
    func scrollToBottom()
    func startFromRowAt(row: Int, section: Int)
    func startFromRowAt(minus count: Int)
}

final class ChatLogView: UIView {
    // MARK: Properties
    
    var sendMessageButtonAction: Completions.ButtonPress?
    var pullToRefreshAction: Completions.ButtonPress?
    
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
    
    private let textContainerView = UIView()
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
    
    func endRefreshing() {
        tableView.refreshControl?.endRefreshing()
    }
    
    func clearTextView() {
        textView.text = nil
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func updateRowAt(row: Int, section: Int) {
        let indexPath = IndexPath(row: row, section: section)
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func insertNewRow() {
        let sectionsCount = tableView.numberOfSections
        
        if 0 < sectionsCount {
            let lastSection = sectionsCount - 1
            
            let lastRowIndex = tableView.numberOfRows(inSection: lastSection)
            let lastRowIndexPath = IndexPath(row: lastRowIndex, section: lastSection)
            
            tableView.insertRows(at: [lastRowIndexPath], with: .bottom)
        }
    }
    
    func scrollToBottom() {
        let sectionsCount = tableView.numberOfSections
        
        if 0 < sectionsCount {
            let lastSection = sectionsCount - 1
            let rowsCount = tableView.numberOfRows(inSection: lastSection)
            
            if 0 < rowsCount {
                let lastRow = rowsCount - 1
            
                startFromRowAt(row: lastRow, section: lastSection)
            }
        }
    }
    
    func startFromRowAt(row: Int, section: Int) {
        let lastRow = tableView.numberOfRows(inSection: section) - 1
        
        if 1 < lastRow {
            var currentRow = lastRow
            
            if row < lastRow {
                currentRow -= row
            }
            
            let indexPath = IndexPath(row: currentRow, section: section)
            
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
    
    func startFromRowAt(minus count: Int) {
        let sectionsCount = tableView.numberOfSections
        
        if 0 < sectionsCount {
            var excludeCount = count
            
            var section = 0
            var rowsCount = 0
            
            for currentSection in stride(from: sectionsCount - 1, through: 0, by: -1) {
                section = currentSection
                rowsCount = tableView.numberOfRows(inSection: currentSection)
                
                if rowsCount < excludeCount {
                    excludeCount -= rowsCount
                } else {
                    break
                }
            }
            
            let rowsInSection = rowsCount - excludeCount
            
            if 0 < rowsInSection {
                startFromRowAt(row: rowsInSection - 1, section: section)
            }
        }
    }
}

// MARK: - Appearance

private extension ChatLogView {
    func setupAppearance() {
        setupTableViewAppearance()
        
        setupTextContainerViewAppearance()
        setupTextViewAppearance()
        setupSendButtonAppearance()
    }
    
    func setupTableViewAppearance() {
        tableView.backgroundColor = UIColor(white: 0.98, alpha: 1)
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
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
    
    @objc func didPullToRefresh() {
        pullToRefreshAction?()
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
