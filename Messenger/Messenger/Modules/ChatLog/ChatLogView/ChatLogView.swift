//
//  ChatLogView.swift
//  Messenger
//
//  Created by Admin on 26.11.2020.
//

import UIKit

protocol ChatLogViewDelegate: AnyObject {
    func chatLogViewDidPressSendButton(_ chatLogView: ChatLogView)
    func chatLogViewPullToRefresh(_ chatLogView: ChatLogView)
}

final class ChatLogView: UIView {
    // MARK: Properties
    
    weak var delegate: ChatLogViewDelegate?
    
    var tableViewDataSource: UITableViewDataSource? {
        get { tableView.dataSource }
        set { tableView.dataSource = newValue }
    }
    
    var tableViewDelegate: UITableViewDelegate? {
        get { tableView.delegate }
        set { tableView.delegate = newValue }
    }
    
    private enum Constants {
        static let textViewFontSize: CGFloat = 18
        static let textViewCornerRadius: CGFloat = 8
        static let textViewBorderWidth: CGFloat = 1
        static let textViewBorderColor = UIColor.systemGray3
        static let textViewPlaceholder = "Write a message..."
        
        static let keyboardAnimationDuration = 0.1
        
        static let tableViewVerticalInset: CGFloat = 8
        static let tableViewBackgroundColor = UIColor(white: 0.98, alpha: 1)
    }
    
    private enum Metrics {
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 8
    }
    
    private var textContainerViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: Subviews
    
    let tableView = UITableView()
    
    private let textContainerView = UIView()
    private let textView = InputTextView()
    
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

// MARK: - Public Methods

extension ChatLogView {
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
        } else {
            tableView.reloadData()
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

// MARK: - Private Methods

private extension ChatLogView {
    func setupViewDelegates() {
        textView.delegate = self
        textView.sendDelegate = self
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
}

// MARK: - Appearance

private extension ChatLogView {
    func setupAppearance() {
        setupTableViewAppearance()
        
        setupTextContainerViewAppearance()
        setupTextViewAppearance()
    }
    
    func setupTableViewAppearance() {
        tableView.backgroundColor = Constants.tableViewBackgroundColor
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: Constants.tableViewVerticalInset,
                                              left: 0,
                                              bottom: Constants.tableViewVerticalInset,
                                              right: 0)
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.reuseIdentifier)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    func setupTextContainerViewAppearance() {
        textContainerView.backgroundColor = Colors.themeColor
        textContainerView.layer.borderColor = Colors.themeSecondColor.cgColor
        textContainerView.sizeToFit()
    }
    
    func setupTextViewAppearance() {
        textView.placeholderText = Constants.textViewPlaceholder
        
        textView.layer.borderWidth = Constants.textViewBorderWidth
        textView.layer.borderColor = Constants.textViewBorderColor.cgColor
        textView.layer.cornerRadius = Constants.textViewCornerRadius
        
        textView.font = .systemFont(ofSize: Constants.textViewFontSize)
        textView.isScrollEnabled = false
        
        textView.sizeToFit()
    }
}

// MARK: - Actions

private extension ChatLogView {
    @objc func didPullToRefresh() {
        delegate?.chatLogViewPullToRefresh(self)
    }
}

// MARK: - Layout

private extension ChatLogView {
    func setupLayout() {
        setupSubviews()
        
        setupTableViewLayout()
        
        setupTextContainerViewLayout()
        setupTextViewLayout()
    }
    
    func setupSubviews() {
        addSubview(tableView)
        addSubview(textContainerView)
        
        textContainerView.addSubview(textView)
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
            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor, constant: Metrics.verticalSpace),
            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor, constant: -Metrics.verticalSpace),
            textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor,
                                              constant: Metrics.horizontalSpace),
            textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor,
                                               constant: -Metrics.horizontalSpace),
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
        
        UIView.animate(withDuration: Constants.keyboardAnimationDuration) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textContainerViewBottomConstraint?.constant = 0

        UIView.animate(withDuration: Constants.keyboardAnimationDuration) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - UITextViewDelegate

extension ChatLogView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let textView = textView as? InputTextView else { return }
        
        if let text = textView.text {
            if text.isEmpty {
                textView.showPlaceholder()
                textView.hideSendButton()
            } else if text.count <= 1 {
                textView.hidePlaceholder()
                textView.showSendButton()
            }
        }
    }
}

// MARK: - InputTextViewDelegate

extension ChatLogView: InputTextViewDelegate {
    func inputTextViewDidPressSendButton(_ textView: InputTextView) {
        delegate?.chatLogViewDidPressSendButton(self)
        
        textView.showPlaceholder()
        textView.hideSendButton()
        textView.text = nil
    }
}
