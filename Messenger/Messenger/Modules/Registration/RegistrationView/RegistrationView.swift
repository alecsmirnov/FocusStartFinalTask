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
    
    var firstNameText: String? { get }
    var lastNameText: String? { get }
    var emailText: String? { get }
    var passwordText: String? { get }
    
    func showSpinnerView()
    func hideSpinnerView()
}

final class RegistrationView: UIView {
    // MARK: Properties
    
    var signUpButtonAction: Completions.ButtonPress?
    var signInButtonAction: Completions.ButtonPress?
    
    // MARK: Subviews
    
    private let spinnerView = SpinnerView()
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
    
    func showSpinnerView() {
        spinnerView.show()
    }
    
    func hideSpinnerView() {
        spinnerView.hide()
    }
}

// MARK: - Appearance

private extension RegistrationView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupFirstNameTextFieldAppearance()
        setupLastNameTextFieldAppearance()
        
        setupEmailTextFieldAppearance()
        setupPasswordTextFieldAppearance()
        
        setupSignUpButtonAppearance()
        
        setupPromptLabelAppearance()
        setupSignInButtonAppearance()
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
        passwordTextField.returnKeyType = .done
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.sizeToFit()
    }
    
    func setupSignUpButtonAppearance() {
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(LoginRegistrationColors.buttonTitle, for: .normal)
        signUpButton.backgroundColor = Colors.themeColor
        signUpButton.clipsToBounds = true
        signUpButton.sizeToFit()
        
        signUpButton.layer.borderWidth = LoginRegistrationMetrics.borderWidth
        signUpButton.layer.borderColor = Colors.themeSecondColor.cgColor
        signUpButton.layer.cornerRadius = LoginRegistrationMetrics.cornerRadius
        
        signUpButton.addTarget(self, action: #selector(didPressSignUpButton), for: .touchUpInside)
    }
    
    func setupPromptLabelAppearance() {
        promptLabel.text = "Have an account?"
        promptLabel.font = .systemFont(ofSize: LoginRegistrationMetrics.promptFontSize)
        promptLabel.sizeToFit()
    }
    
    func setupSignInButtonAppearance() {
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(LoginRegistrationColors.link, for: .normal)
        signInButton.titleLabel?.font = .boldSystemFont(ofSize: LoginRegistrationMetrics.promptFontSize)
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
        addSubview(containerView)
        addSubview(spinnerView)
        
        containerView.addSubview(firstNameTextField)
        containerView.addSubview(lastNameTextField)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        
        containerView.addSubview(signUpButton)
        
        containerView.addSubview(signInView)
        signInView.addSubview(promptLabel)
        signInView.addSubview(signInButton)
    }
    
    func setupContainerViewLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                   constant: LoginRegistrationMetrics.horizontalSpace),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                    constant: -LoginRegistrationMetrics.horizontalSpace),
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
    
    func setupPasswordTextFieldLayout() {
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor,
                                                   constant: LoginRegistrationMetrics.verticalSpace),
            passwordTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }
    
    func setupSignUpButtonLayout() {
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,
                                              constant: LoginRegistrationMetrics.verticalSpace),
            signUpButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: LoginRegistrationMetrics.buttonHeight),
        ])
    }
    
    func setupSignInViewLayout() {
        signInView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor,
                                            constant: LoginRegistrationMetrics.signInVerticalSpace),
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
                                                  constant: -LoginRegistrationMetrics.signInHorizontalSpace),
        ])
    }
    
    func setupSignInButtonLayout() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: signInView.topAnchor),
            signInButton.bottomAnchor.constraint(equalTo: signInView.bottomAnchor),
            signInButton.leadingAnchor.constraint(equalTo: promptLabel.trailingAnchor,
                                                  constant: LoginRegistrationMetrics.signInHorizontalSpace),
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
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if textField == passwordTextField && !passwordTextField.isSecureTextEntry {
            passwordTextField.isSecureTextEntry = true
        }
        
        return true
    }
}
