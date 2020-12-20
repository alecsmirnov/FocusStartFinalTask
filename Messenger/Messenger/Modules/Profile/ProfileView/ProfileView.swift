//
//  ProfileView.swift
//  Messenger
//
//  Created by Admin on 19.12.2020.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func profileViewDidPressCloseButton(_ profileView: ProfileView)
    func profileViewDidPressSaveButton(_ profileView: ProfileView)
    func profileViewDidTapProfileImage(_ profileView: ProfileView)
}

final class ProfileView: UIView {
    // MARK: Properties
    
    weak var delegate: ProfileViewDelegate?
    
    private enum Metrics {
        static let headerTopSpace: CGFloat = 20
        
        static let verticalSpace: CGFloat = 8
        static let horizontalSpace: CGFloat = 16
        
        static let profileImageSize: CGFloat = 54
        
        static let tableViewRowHeight: CGFloat = 30
        
        static let buttonWidth: CGFloat = 200
    }
    
    // MARK: Subviews
    
    private let spinnerView = SpinnerView()
    
    private let headerView = UIView()
    private let profileImageImageView = InitialsImageView()
    private let profileImageButton = UIButton(type: .system)
    
    private let containerView = UIView()
    
    private let firstNameTextField = UITextField()
    private let lastNameTextField = UITextField()
    private let emailTextField = UITextField()

    private let closeButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)
        
        setupAppearance()
        setupLayout()
        setupActions()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawProfilePhotoImageView()
    }
}

// MARK: - Draw

private extension ProfileView {
    func drawProfilePhotoImageView() {
        profileImageImageView.layer.cornerRadius = profileImageImageView.frame.size.height / 2
        profileImageImageView.clipsToBounds = true
    }
}

// MARK: - Public Methods

extension ProfileView {
    func setUser(_ user: UserInfo) {
        firstNameText = user.firstName
        lastNameText = user.lastName
        emailText = user.email
        
        if let profileImageURL = user.profileImageURL {
            profileImageImageView.download(urlString: profileImageURL)
        } else {
            profileImageImageView.showInitials(firstName: user.firstName, lastName: user.lastName)
            profileImageImageView.backgroundColor = .black
        }
    }
    
    var profileImage: UIImage? {
        get { profileImageImageView.image }
        set { profileImageImageView.image = newValue }
    }
    
    var firstNameText: String? {
        get { firstNameTextField.text }
        set { firstNameTextField.text = newValue }
    }
    
    var lastNameText: String? {
        get { lastNameTextField.text }
        set { lastNameTextField.text = newValue }
    }
    
    var emailText: String? {
        get { emailTextField.text }
        set { emailTextField.text = newValue }
    }
    
    func showSpinnerView() {
        spinnerView.show()
    }
    
    func hideSpinnerView() {
        spinnerView.hide()
    }
}

// MARK: - Appearance

private extension ProfileView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupProfileImageImageViewAppearance()
        setupProfileImageButtonAppearance()
        
        setupFirstNameTextFieldAppearance()
        setupLastNameTextFieldAppearance()
        setupEmailTextFieldAppearance()
        
        setupCloseButtonAppearance()
        setupSaveButtonAppearance()
    }
    
    func setupProfileImageImageViewAppearance() {
        profileImageImageView.contentMode = .scaleAspectFit
    }
    
    func setupProfileImageButtonAppearance() {
        profileImageButton.setTitle("Set Profile Photo", for: .normal)
        profileImageButton.setTitleColor(.black, for: .normal)
        profileImageButton.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    func setupFirstNameTextFieldAppearance() {
        firstNameTextField.placeholder = "First name"
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.returnKeyType = .continue
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none
        firstNameTextField.textColor = .darkGray
        firstNameTextField.sizeToFit()
    }
    
    func setupLastNameTextFieldAppearance() {
        lastNameTextField.placeholder = "Last name (optional)"
        lastNameTextField.borderStyle = .roundedRect
        lastNameTextField.returnKeyType = .continue
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
        lastNameTextField.textColor = .darkGray
        lastNameTextField.sizeToFit()
    }
    
    func setupEmailTextFieldAppearance() {
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.returnKeyType = .continue
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.textColor = .darkGray
        emailTextField.sizeToFit()
    }
    
    func setupCloseButtonAppearance() {
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(LoginRegistrationColors.buttonTitle, for: .normal)
        closeButton.backgroundColor = Colors.themeColor
        closeButton.clipsToBounds = true
        closeButton.sizeToFit()
        
        closeButton.layer.borderWidth = LoginRegistrationMetrics.borderWidth
        closeButton.layer.borderColor = Colors.themeSecondColor.cgColor
        closeButton.layer.cornerRadius = LoginRegistrationMetrics.cornerRadius
    }
    
    func setupSaveButtonAppearance() {
        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(LoginRegistrationColors.buttonTitle, for: .normal)
        saveButton.backgroundColor = Colors.themeColor
        saveButton.clipsToBounds = true
        saveButton.sizeToFit()
        
        saveButton.layer.borderWidth = LoginRegistrationMetrics.borderWidth
        saveButton.layer.borderColor = Colors.themeSecondColor.cgColor
        saveButton.layer.cornerRadius = LoginRegistrationMetrics.cornerRadius
    }
}

// MARK: - Layouts

private extension ProfileView{
    func setupLayout() {
        setupSubviews()
 
        setupHeaderViewLayout()
        setupProfileImageImageViewLayout()
        setupProfileImageButtonLayout()
        
        setupContainerViewLayout()
        
        setupFirstNameTextFieldLayout()
        setupLastNameTextFieldLayout()
        
        setupEmailTextFieldLayout()
        
        setupCloseButtonLayout()
        setupSaveButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(headerView)
        addSubview(containerView)
        addSubview(spinnerView)
        
        headerView.addSubview(profileImageImageView)
        headerView.addSubview(profileImageButton)
        
        containerView.addSubview(firstNameTextField)
        containerView.addSubview(lastNameTextField)
        containerView.addSubview(emailTextField)
        containerView.addSubview(closeButton)
        containerView.addSubview(saveButton)
    }
    
    func setupHeaderViewLayout() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func setupProfileImageImageViewLayout() {
        profileImageImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: Metrics.headerTopSpace),
            profileImageImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageImageView.heightAnchor.constraint(equalToConstant: Metrics.profileImageSize),
            profileImageImageView.widthAnchor.constraint(equalToConstant: Metrics.profileImageSize),
        ])
    }
    
    func setupProfileImageButtonLayout() {
        profileImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: profileImageImageView.bottomAnchor,
                                                    constant: Metrics.verticalSpace),
            profileImageButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor,
                                                       constant: -Metrics.verticalSpace),
            profileImageButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
        ])
    }
    
    func setupContainerViewLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                   constant: LoginRegistrationMetrics.horizontalSpace),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -LoginRegistrationMetrics.horizontalSpace),
        ])
    }
    
    func setupFirstNameTextFieldLayout() {
        firstNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            firstNameTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
            firstNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            firstNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupLastNameTextFieldLayout() {
        lastNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor,
                                                   constant: LoginRegistrationMetrics.verticalSpace),
            lastNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupEmailTextFieldLayout() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor,
                                                constant: LoginRegistrationMetrics.verticalSpace),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupCloseButtonLayout() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: saveButton.bottomAnchor,
                                             constant: LoginRegistrationMetrics.verticalSpace),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: LoginRegistrationMetrics.buttonHeight),
        ])
    }
    
    func setupSaveButtonLayout() {
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saveButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,
                                            constant: Metrics.headerTopSpace),
            saveButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: LoginRegistrationMetrics.buttonHeight),
        ])
    }
}

// MARK: - Actions

private extension ProfileView {
    func setupActions() {
        setupProfileImageViewAction()
        setupProfileImageButtonAction()
        setupCloseButtonAction()
        setupSaveButtonAction()
    }
    
    func setupProfileImageViewAction() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))

        profileImageImageView.isUserInteractionEnabled = true
        profileImageImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupProfileImageButtonAction() {
        profileImageButton.addTarget(self, action: #selector(didTapProfileImageView), for: .touchUpInside)
    }
    
    func setupCloseButtonAction() {
        closeButton.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
    }
    
    func setupSaveButtonAction() {
        saveButton.addTarget(self, action: #selector(didPressSaveButton), for: .touchUpInside)
    }
    
    @objc func didTapProfileImageView() {
        delegate?.profileViewDidTapProfileImage(self)
    }
    
    @objc func didPressCloseButton() {
        delegate?.profileViewDidPressCloseButton(self)
    }
    
    @objc func didPressSaveButton() {
        delegate?.profileViewDidPressSaveButton(self)
    }
}

// MARK: - Gestures

private extension ProfileView {
    func setupGestures() {
        setupTextFieldDelegates()
        setupTapGestureRecognizer()
    }
    
    func setupTextFieldDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension ProfileView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField: lastNameTextField.becomeFirstResponder()
        case lastNameTextField: emailTextField.becomeFirstResponder()
        case emailTextField: emailTextField.resignFirstResponder()
        default: break
        }
        
        return true
    }
}
