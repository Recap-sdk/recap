//
//  FamilyLoginViewController.swift
//  recap
//
//  Created by user@47 on 29/01/25.
//

import UIKit

class FamilyLoginViewController: UIViewController {
    var verifiedUserDocID: String?
    var isRemembered = true
    
    // MARK: - UI Components
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "recapLogo")
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login 👋"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    let patientUIDField: UITextField = {
        let field = UITextField()
        field.placeholder = "Patient UID"
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.autocapitalizationType = .none
        return field
    }()
    
    let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return button
    }()
    
    let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email address"
        field.keyboardType = .emailAddress
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.autocapitalizationType = .none
        field.isEnabled = false  // Initially disabled
        return field
    }()
    
    let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = 12
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.isEnabled = false  // Initially disabled
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        field.rightView = button
        field.rightViewMode = .always
        
        return field
    }()
    
    let rememberMeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Remember me", for: .normal)  // Space for better alignment
        button.tintColor = .black
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)  // Default checked
        button.tintColor = .systemBlue
        return button
    }()
    
    fileprivate let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password?", for: .normal)
        button.tintColor = .black
        return button
    }()
    
    fileprivate let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Family Login"
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if isUserLoggedIn {
            if let savedEmail = UserDefaults.standard.string(forKey: "savedEmail"),
               let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
                emailField.text = savedEmail
                passwordField.text = savedPassword
                
                // Auto-login
                loginTapped()
            }
        }
        setupUI()
        let Dismisskeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
                view.addGestureRecognizer(Dismisskeyboard)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        [logoImageView, titleLabel, patientUIDField, verifyButton, emailField, passwordField,
         rememberMeButton, forgotPasswordButton, loginButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            patientUIDField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            patientUIDField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            patientUIDField.trailingAnchor.constraint(equalTo: verifyButton.leadingAnchor, constant: -10),
            patientUIDField.heightAnchor.constraint(equalToConstant: 50),
            
            verifyButton.centerYAnchor.constraint(equalTo: patientUIDField.centerYAnchor),
            verifyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            verifyButton.widthAnchor.constraint(equalToConstant: 80),
            verifyButton.heightAnchor.constraint(equalToConstant: 50),
            
            emailField.topAnchor.constraint(equalTo: patientUIDField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            rememberMeButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
            rememberMeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            forgotPasswordButton.centerYAnchor.constraint(equalTo: rememberMeButton.centerYAnchor),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginButton.topAnchor.constraint(equalTo: rememberMeButton.bottomAnchor, constant: 30),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add targets (Fixed function name)
        rememberMeButton.addTarget(self, action: #selector(toggleRememberMe), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        verifyButton.addTarget(self, action: #selector(verifyPatientUID), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    @objc private func toggleRememberMe() {
        isRemembered.toggle()
        let imageName = isRemembered ? "checkmark.circle.fill" : "circle"
        rememberMeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

#Preview { FamilyLoginViewController() }
