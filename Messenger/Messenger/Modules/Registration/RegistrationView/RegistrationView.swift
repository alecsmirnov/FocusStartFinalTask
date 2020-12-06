//
//  RegistrationView.swift
//  Messenger
//
//  Created by Admin on 22.11.2020.
//

import UIKit

protocol IRegistrationView: AnyObject {
    var signUpButtonAction: Completions.ButtonPress? { get set }
    var signInButtonAction: Completions.ButtonPress? { get set }
    
    var activityIndicator: Bool { get set }
    
    var firstNameText: String? { get }
    var lastNameText: String? { get }
    var emailText: String? { get }
    var passwordText: String? { get }
}

class RegistrationView: UIView {
    // MARK: Properties
    
    var signUpButtonAction: Completions.ButtonPress?
    var signInButtonAction: Completions.ButtonPress?
    
    // MARK: Subviews
    
    private let activityIndicatorView = UIActivityIndicatorView()

    private let containerView = UIView()
    
    private let firstNameTextField = UITextField()
    private let lastNameTextField = UITextField()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()

    private let signUpButton = UIButton(type: .system)
    
    private let signInView = UIView()
    private let promptLabel = UILabel()
    private let signInButton = UIButton(type: .system)
    
    // MARK: Initialization
    
    init() {
        super.init(frame: .zero)
        
        setupAppearance()
        setupLayout()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - IRegistrationView

extension RegistrationView: IRegistrationView {
    var activityIndicator: Bool {
        get { activityIndicatorView.isAnimating }
        set {
            containerView.isHidden = newValue
            
            newValue ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        }
    }
    
    var firstNameText: String? {
        return firstNameTextField.text
    }
    
    var lastNameText: String? {
        return lastNameTextField.text
    }
    
    var emailText: String? {
        return emailTextField.text
    }
    
    var passwordText: String? {
        return passwordTextField.text
    }
}

// MARK: - Appearance

private extension RegistrationView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupActivityIndicatorViewAppearance()
        
        setupFirstNameTextFieldAppearance()
        setupLastNameTextFieldAppearance()
        
        setupEmailTextFieldAppearance()
        setupPasswordTextFieldAppearance()
        
        setupSignUpButtonAppearance()
        
        setupPromptLabelAppearance()
        setupSignInButtonAppearance()
    }
    
    func setupActivityIndicatorViewAppearance() {
        activityIndicatorView.color = .black
    }
    
    func setupFirstNameTextFieldAppearance() {
        firstNameTextField.placeholder = "First name"
        firstNameTextField.borderStyle = .roundedRect
        firstNameTextField.returnKeyType = .continue
        firstNameTextField.autocorrectionType = .no
        firstNameTextField.autocapitalizationType = .none
        firstNameTextField.sizeToFit()
    }
    
    func setupLastNameTextFieldAppearance() {
        lastNameTextField.placeholder = "Last name (optional)"
        lastNameTextField.borderStyle = .roundedRect
        lastNameTextField.returnKeyType = .continue
        lastNameTextField.autocorrectionType = .no
        lastNameTextField.autocapitalizationType = .none
        lastNameTextField.sizeToFit()
    }
    
    func setupEmailTextFieldAppearance() {
        emailTextField.placeholder = "Email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.returnKeyType = .continue
        emailTextField.autocorrectionType = .no
        emailTextField.autocapitalizationType = .none
        emailTextField.sizeToFit()
    }
    
    func setupPasswordTextFieldAppearance() {
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.returnKeyType = .done
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.sizeToFit()
    }
    
    func setupSignUpButtonAppearance() {
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(Colors.buttonTitle, for: .normal)
        signUpButton.backgroundColor = Colors.buttonBackground
        signUpButton.clipsToBounds = true
        signUpButton.sizeToFit()
        
        signUpButton.layer.borderWidth = Metrics.borderWidth
        signUpButton.layer.cornerRadius = Metrics.cornerRadius
        
        signUpButton.addTarget(self, action: #selector(didPressSignUpButton), for: .touchUpInside)
    }
    
    func setupPromptLabelAppearance() {
        promptLabel.text = "Have an account?"
        promptLabel.font = .systemFont(ofSize: Metrics.promptFontSize)
        promptLabel.sizeToFit()
    }
    
    func setupSignInButtonAppearance() {
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(Colors.link, for: .normal)
        signInButton.titleLabel?.font = .boldSystemFont(ofSize: Metrics.promptFontSize)
        signInButton.sizeToFit()
        
        signInButton.addTarget(self, action: #selector(didPressSignInButton), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension RegistrationView {
    @objc func didPressSignUpButton() {
        signUpButtonAction?()
    }
    
    @objc func didPressSignInButton() {
        signInButtonAction?()
    }
}

// MARK: - Layouts

private extension RegistrationView{
    func setupLayout() {
        setupSubviews()
        
        setupActivityIndicatorViewLayout()
        
        setupContainerViewLayout()
        
        setupFirstNameTextFieldLayout()
        setupLastNameTextFieldLayout()
        
        setupEmailTextFieldLayout()
        setupPasswordTextFieldLayout()
        
        setupSignUpButtonLayout()
        
        setupSignInViewLayout()
        setupPromptLabelLayout()
        setupSignInButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(activityIndicatorView)
        addSubview(containerView)
        
        containerView.addSubview(firstNameTextField)
        containerView.addSubview(lastNameTextField)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        
        containerView.addSubview(signUpButton)
        
        containerView.addSubview(signInView)
        signInView.addSubview(promptLabel)
        signInView.addSubview(signInButton)
    }
    
    func setupActivityIndicatorViewLayout() {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: containerView.topAnchor,
                                                          constant: -Metrics.verticalSpace),
        ])
    }
    
    func setupContainerViewLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                   constant: Metrics.horizontalSpace),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -Metrics.horizontalSpace),
            containerView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
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
                                                   constant: Metrics.verticalSpace),
            lastNameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupEmailTextFieldLayout() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor,
                                                constant: Metrics.verticalSpace),
            emailTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupPasswordTextFieldLayout() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,
                                                   constant: Metrics.verticalSpace),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupSignUpButtonLayout() {
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: Metrics.verticalSpace),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: Metrics.buttonHeight),
        ])
    }
    
    func setupSignInViewLayout() {
        signInView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: Metrics.signInVerticalSpace),
            signInView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            signInView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
    }
    
    func setupPromptLabelLayout() {
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: signInView.topAnchor),
            promptLabel.bottomAnchor.constraint(equalTo: signInView.bottomAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: signInView.leadingAnchor),
            promptLabel.trailingAnchor.constraint(equalTo: signInButton.leadingAnchor,
                                                  constant: -Metrics.signInHorizontalSpace),
        ])
    }
    
    func setupSignInButtonLayout() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: signInView.topAnchor),
            signInButton.bottomAnchor.constraint(equalTo: signInView.bottomAnchor),
            signInButton.leadingAnchor.constraint(equalTo: promptLabel.trailingAnchor,
                                                  constant: Metrics.signInHorizontalSpace),
            signInButton.trailingAnchor.constraint(equalTo: signInView.trailingAnchor),
        ])
    }
}

// MARK: - Gestures

private extension RegistrationView {
    func setupGestures() {
        setupTextFieldDelegates()
        setupTapGestureRecognizer()
    }
    
    func setupTextFieldDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
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

extension RegistrationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField: lastNameTextField.becomeFirstResponder()
        case lastNameTextField: emailTextField.becomeFirstResponder()
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: passwordTextField.resignFirstResponder(); signUpButtonAction?()
        default: break
        }
        
        return true
    }
}
