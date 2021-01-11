//
//  MenuView.swift
//  Messenger
//
//  Created by Admin on 07.12.2020.
//

import UIKit

protocol MenuViewDelegate: AnyObject {
    func menuView(_ menuView: MenuView, didSelectMenuOption menuOption: MenuView.MenuOptions)
}

final class MenuView: UIView {
    // MARK: Properties
    
    weak var delegate: MenuViewDelegate?
    
    enum MenuOptions: Int {
        case editProfile
        case signOut
        
        static let count = signOut.rawValue + 1
        
        var description: String {
            switch self {
            case .editProfile: return "Edit profile"
            case .signOut: return "Sign out"
            }
        }
        
        var image: UIImage? {
            switch self {
            case .editProfile: return Constants.editProfileImage
            case .signOut: return Constants.signOutImage
            }
        }
    }
    
    private enum Constants {
        static let nameLabelFontSize: CGFloat = 17
        static let emailLabelFontSize: CGFloat = 15
        
        static let editProfileImage = UIImage(systemName: "person")
        static let signOutImage = UIImage(systemName: "xmark")
    }
    
    private enum Metrics {
        static let headerViewHeight: CGFloat = 100
        
        static let verticalSpace: CGFloat = 4
        static let horizontalSpace: CGFloat = 16
        
        static let tableViewRowHeight: CGFloat = 40
        static let tableViewTopInset: CGFloat = 16
    }
    
    private var menuOptionsCount = MenuOptions.count
    
    // MARK: Subviews
    
    private let headerView = UIView()
    private let profileImageImageView = InitialsImageView()
    
    private let infoView = UILabel()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    
    private let tableView = UITableView()
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)

        setupAppearance()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawProfilePhotoImageView()
    }
}

// MARK: - Public Methods

extension MenuView {
    func setUser(_ user: UserInfo) {
        nameLabel.text = "\(user.firstName) \(user.lastName ?? "")"
        emailLabel.text = user.email
        
        if let profileImageURL = user.profileImageURL {
            profileImageImageView.download(urlString: profileImageURL)
        } else {
            profileImageImageView.showInitials(firstName: user.firstName, lastName: user.lastName)
            profileImageImageView.backgroundColor = Colors.initialsViewBackgroundColor
        }
    }
    
    func showOptions() {
        menuOptionsCount = MenuOptions.count
        
        tableView.reloadData()
    }
    
    func hideOptions() {
        menuOptionsCount = 0
        
        tableView.reloadData()
    }
}

// MARK: - Draw

private extension MenuView {
    func drawProfilePhotoImageView() {
        profileImageImageView.layer.cornerRadius = profileImageImageView.frame.size.height / 2
        profileImageImageView.clipsToBounds = true
    }
}

// MARK: - Appearance

private extension MenuView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupHeadViewAppearance()
        setupProfileImageImageViewAppearance()
        setupNameLabelAppearance()
        setupEmailLabelAppearance()
        setupTableViewAppearance()
    }
    
    func setupHeadViewAppearance() {
        headerView.backgroundColor = Colors.themeColor
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.contentMode = .scaleAspectFill
    }
    
    func setupNameLabelAppearance() {
        nameLabel.font = .boldSystemFont(ofSize: Constants.nameLabelFontSize)
        nameLabel.textColor = .white
    }
    
    func setupEmailLabelAppearance() {
        emailLabel.font = .boldSystemFont(ofSize: Constants.emailLabelFontSize)
        emailLabel.textColor = .white
    }
    
    func setupTableViewAppearance() {
        tableView.separatorStyle = .none
        
        tableView.register(MenuOptionCell.self, forCellReuseIdentifier: MenuOptionCell.reuseIdentifier)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: - Layout

private extension MenuView {
    func setupLayout() {
        setupSubviews()
        
        setupHeaderViewLayout()
        setupProfileImageImageViewLayout()
        setupInfoViewLayout()
        setupNameLabelLayout()
        setupEmailLabelLayout()
        setupTableViewLayout()
    }
    
    func setupSubviews() {
        addSubview(headerView)
        addSubview(tableView)
        
        headerView.addSubview(profileImageImageView)
        headerView.addSubview(infoView)
        
        infoView.addSubview(nameLabel)
        infoView.addSubview(emailLabel)
    }
    
    func setupHeaderViewLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: Metrics.headerViewHeight),
        ])
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor,
                                                           constant: Metrics.horizontalSpace),
            profileImageImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            profileImageImageView.heightAnchor.constraint(equalToConstant: SharedMetrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: SharedMetrics.profileImageSize),
        ])
    }
    
    func setupInfoViewLayout() {
        infoView.translatesAutoresizingMaskIntoConstraints = false
 
        NSLayoutConstraint.activate([
            infoView.leadingAnchor.constraint(equalTo: profileImageImageView.trailingAnchor,
                                              constant: Metrics.horizontalSpace),
            infoView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor,
                                               constant: -Metrics.horizontalSpace),
            infoView.centerYAnchor.constraint(equalTo: profileImageImageView.centerYAnchor),
        ])
    }
    
    func setupNameLabelLayout() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: infoView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
        ])
    }
    
    func setupEmailLabelLayout() {
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: Metrics.verticalSpace),
            emailLabel.bottomAnchor.constraint(equalTo: infoView.bottomAnchor),
            emailLabel.leadingAnchor.constraint(equalTo: infoView.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: infoView.trailingAnchor),
        ])
    }
    
    func setupTableViewLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.contentInset = UIEdgeInsets(top: Metrics.tableViewTopInset, left: 0, bottom: 0, right: 0)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension MenuView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return Metrics.tableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuOptionsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuOptionCell.reuseIdentifier,
                                                       for: indexPath) as? MenuOptionCell else {
            return UITableViewCell()
        }
        
        if let menuOption = MenuOptions(rawValue: indexPath.row) {
            cell.configure(with: menuOption.description, and: menuOption.image)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MenuView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let menuOption = MenuOptions(rawValue: indexPath.row) {
            delegate?.menuView(self, didSelectMenuOption: menuOption)
        }
    }
}
