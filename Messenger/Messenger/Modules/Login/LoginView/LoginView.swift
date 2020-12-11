//
//  LoginView.swift
//  Messenger
//
//  Created by Admin on 21.11.2020.
//

import UIKit

protocol ILoginView: AnyObject {
    var signInButtonAction: Completions.ButtonPress? { get set }
    var signUpButtonAction: Completions.ButtonPress? { get set }

    var emailText: String? { get }
    var passwordText: String? { get }
    
    func showSpinnerView()
    func hideSpinnerView()
}

final class LoginView: UIView {
    // MARK: Properties
    
    var signInButtonAction: Completions.ButtonPress?
    var signUpButtonAction: Completions.ButtonPress?
    
    // MARK: Subviews
    
    private let spinnerView = SpinnerView()
    private let containerView = UIView()
    
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    
    private let signInButton = UIButton(type: .system)
    
    private let signUpView = UIView()
    private let promptLabel = UILabel()
    private let signUpButton = UIButton(type: .system)

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

// MARK: - ILoginView

extension LoginView: ILoginView {
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

private extension LoginView {
    func setupAppearance() {
        backgroundColor = .systemBackground
        
        setupEmailTextFieldAppearance()
        setupPasswordTextFieldAppearance()
        
        setupSignInButtonAppearance()
        
        setupPromptLabelAppearance()
        setupSignUpButtonAppearance()
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
    
    func setupSignInButtonAppearance() {
        signInButton.setTitle("Sign in", for: .normal)
        signInButton.setTitleColor(LoginRegistrationColors.buttonTitle, for: .normal)
        signInButton.backgroundColor = LoginRegistrationColors.buttonBackground
        signInButton.clipsToBounds = true
        signInButton.sizeToFit()
        
        signInButton.layer.borderWidth = LoginRegistrationMetrics.borderWidth
        signInButton.layer.cornerRadius = LoginRegistrationMetrics.cornerRadius
        
        signInButton.addTarget(self, action: #selector(didPressSignInButton), for: .touchUpInside)
    }
    
    func setupPromptLabelAppearance() {
        promptLabel.text = "Don't have an account?"
        promptLabel.font = .systemFont(ofSize: LoginRegistrationMetrics.promptFontSize)
        promptLabel.sizeToFit()
    }
    
    func setupSignUpButtonAppearance() {
        signUpButton.setTitle("Sign up", for: .normal)
        signUpButton.setTitleColor(LoginRegistrationColors.link, for: .normal)
        signUpButton.titleLabel?.font = .boldSystemFont(ofSize: LoginRegistrationMetrics.promptFontSize)
        signUpButton.sizeToFit()
        
        signUpButton.addTarget(self, action: #selector(didPressSignUpButton), for: .touchUpInside)
    }
}

// MARK: - Actions

private extension LoginView {
    @objc func didPressSignUpButton() {
        signUpButtonAction?()
    }
    
    @objc func didPressSignInButton() {
        signInButtonAction?()
    }
}

// MARK: - Layouts

private extension LoginView {
    func setupLayout() {
        setupSubviews()
        
        setupContainerViewLayout()
        
        setupEmailTextFieldLayout()
        setupPasswordTextFieldLayout()
        
        setupSignUpButtonLayout()
        
        setupSignUpViewLayout()
        setupPromptLabelLayout()
        setupSignInButtonLayout()
    }
    
    func setupSubviews() {
        addSubview(containerView)
        addSubview(spinnerView)
        
        containerView.addSubview(emailTextField)
        containerView.addSubview(passwordTextField)
        
        containerView.addSubview(signInButton)
        
        containerView.addSubview(signUpView)
        signUpView.addSubview(promptLabel)
        signUpView.addSubview(signUpButton)
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
    
    func setupEmailTextFieldLayout() {
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: containerView.topAnchor),
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
    
    func setupSignInButtonLayout() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signInButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor,
                                              constant: LoginRegistrationMetrics.verticalSpace),
            signInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            signInButton.heightAnchor.constraint(equalToConstant: LoginRegistrationMetrics.buttonHeight),
        ])
    }
    
    func setupSignUpViewLayout() {
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpView.topAnchor.constraint(equalTo: signInButton.bottomAnchor,
                                            constant: LoginRegistrationMetrics.signInVerticalSpace),
            signUpView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            signUpView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        ])
    }
    
    func setupPromptLabelLayout() {
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: signUpView.topAnchor),
            promptLabel.bottomAnchor.constraint(equalTo: signUpView.bottomAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: signUpView.leadingAnchor),
            promptLabel.trailingAnchor.constraint(equalTo: signUpButton.leadingAnchor,
                                                  constant: -LoginRegistrationMetrics.signInHorizontalSpace),
        ])
    }
    
    func setupSignUpButtonLayout() {
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            signUpButton.topAnchor.constraint(equalTo: signUpView.topAnchor),
            signUpButton.bottomAnchor.constraint(equalTo: signUpView.bottomAnchor),
            signUpButton.leadingAnchor.constraint(equalTo: promptLabel.trailingAnchor,
                                                  constant: LoginRegistrationMetrics.signInHorizontalSpace),
            signUpButton.trailingAnchor.constraint(equalTo: signUpView.trailingAnchor),
        ])
    }
}

// MARK: - Gestures

private extension LoginView {
    func setupGestures() {
        setupTextFieldDelegates()
        setupTapGestureRecognizer()
    }
    
    func setupTextFieldDelegates() {
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

extension LoginView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField: passwordTextField.becomeFirstResponder()
        case passwordTextField: passwordTextField.resignFirstResponder(); signInButtonAction?()
        default: break
        }
        
        return true
    }
}
