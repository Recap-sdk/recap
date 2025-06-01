//
//  FamilyLoginViewController.swift
//  recap
//
//  Created by user@47 on 29/01/25.
//

import AuthenticationServices
import GoogleSignIn
import UIKit

class FamilyLoginViewController: UIViewController {
    var verifiedUserDocID: String?
    var isRemembered = true
    var currentNonce: String? // Required for Apple Sign-In

    // MARK: - UI Components

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "recapLogo")
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
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
        button.backgroundColor = AppColors.primaryButtonColor
        button.setTitleColor(AppColors.iconColor, for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()

    let googleSignInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black
        config.title = "Sign in with Google"
        config.image = UIImage(named: "googleLogo")?.resized(to: CGSize(width: 24, height: 24))
        config.imagePadding = 16
        config.imagePlacement = .leading
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    let appleSignInButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.title = "Sign in with Apple"

        config.image = UIImage(named: "AppleIcon")?.resized(to: CGSize(width: 24, height: 24))
        config.imagePadding = 16
        config.imagePlacement = .leading
        config.cornerStyle = .medium

        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()

    private let signInStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
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
//                emailField.text = savedEmail
//                passwordField.text = savedPassword

                // Auto-login
//                loginTapped()
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
        [logoImageView, titleLabel, patientUIDField, verifyButton, signInStackView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Add buttons to stack
        signInStackView.addArrangedSubview(googleSignInButton)
        signInStackView.addArrangedSubview(appleSignInButton)

        // Disable sign-in buttons until patient UID is verified
        googleSignInButton.isEnabled = false
        appleSignInButton.isEnabled = false

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

            signInStackView.topAnchor.constraint(equalTo: patientUIDField.bottomAnchor, constant: 30),
            signInStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signInStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signInStackView.heightAnchor.constraint(equalToConstant: 116) // 50 * 2 + 16 spacing
        ])

        // Add targets
        verifyButton.addTarget(self, action: #selector(verifyPatientUID), for: .touchUpInside)
        googleSignInButton.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        appleSignInButton.addTarget(self, action: #selector(appleSignInTapped), for: .touchUpInside)
    }

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
//        passwordField.isSecureTextEntry.toggle()
//        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
//        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }

//    @objc private func toggleRememberMe() {
//        isRemembered.toggle()
//        let imageName = isRemembered ? "checkmark.circle.fill" : "circle"
//        rememberMeButton.setImage(UIImage(systemName: imageName), for: .normal)
//    }
}

#Preview { FamilyLoginViewController() }
