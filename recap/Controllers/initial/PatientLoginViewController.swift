//
//  PatientLoginViewController.swift
//  recap
//
//  Created by Diptayan Jash on 15/12/24.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import GoogleSignIn
import UIKit
import FirebaseFirestore
import Lottie


class PatientLoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    var isRemembered = true

    var currentNonce: String?
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

    let emailField: UITextField = {
        let field = UITextField()
        field.placeholder = "Email address"
        field.keyboardType = .emailAddress
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))

        let iconView = UIImageView(frame: CGRect(x: 13, y: 13, width: 24, height: 24))
        iconView.image = UIImage(systemName: "envelope")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit

        containerView.addSubview(iconView)

        field.leftView = containerView
        field.leftViewMode = .always

        return field
    }()

    let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false

        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))

        let iconView = UIImageView(frame: CGRect(x: 13, y: 13, width: 24, height: 24))
        iconView.image = UIImage(systemName: "lock")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit

        containerView.addSubview(iconView)

        field.leftView = containerView
        field.leftViewMode = .always

        let buttonContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 5, y: 13, width: 24, height: 24)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)

        // Add the button to its container
        buttonContainer.addSubview(button)

        // Set as rightView
        field.rightView = buttonContainer
        field.rightViewMode = .always

        return field
    }()

//    let rememberMeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle(" Remember me", for: .normal)
//        button.tintColor = .black
//        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
//        button.tintColor = .systemBlue
//        return button
//    }()

    fileprivate let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password?", for: .normal)
        button.tintColor = .black
        return button
    }()

    fileprivate let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = AppColors.primaryButtonColor
        button.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let dividerLabel: UILabel = {
        let label = UILabel()
        label.text = "or"
        label.textColor = AppColors.primaryTextColor
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    private let socialButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    fileprivate let googleButton: UIButton = {
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

    fileprivate let appleButton: UIButton = {
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



    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        return button
    }()

    private let signupPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "with email"
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Patient Login"
        setupUI()
        let Dismisskeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Dismisskeyboard)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding

        func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

            return view.window!

        }



        // MARK: - User Profile Management

        

        private func fetchOrCreateUserProfile(userId: String, email: String, loadingAnimation: LottieAnimationView) {

            let db = Firestore.firestore()



            db.collection("users").document(userId).getDocument { [weak self] document, error in

                guard let self = self else { return }



                if let error = error {

                    self.removeLoadingAnimation(loadingAnimation)

                    print("Error fetching user profile: \(error.localizedDescription)")

                    self.showAlert(message: "Failed to fetch user profile.")

                    return

                }



                if let document = document, document.exists {

                    // Existing user profile found

                    let userData = document.data() ?? [:]

                    

                    // Check if profile is complete by verifying required fields

                    let requiredFields = ["firstName", "lastName", "dateOfBirth", "sex", "bloodGroup", "stage"]

                    let isProfileComplete = requiredFields.allSatisfy { field in

                        guard let value = userData[field] as? String else { return false }

                        return !value.isEmpty

                    }

                    

                    if isProfileComplete {

                        // Profile is complete, navigate to main view

                        print("User profile is complete, navigating to main view")

                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isPatientLoggedIn)

                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasPatientCompletedProfile)

                        UserDefaults.standard.synchronize()

                        

                        self.removeLoadingAnimation(loadingAnimation)

                        let tabBarVC = TabbarViewController()

                        self.navigationController?.setViewControllers([tabBarVC], animated: true)

                    } else {

                        // Profile exists but is incomplete, navigate to profile completion

                        print("User profile is incomplete, navigating to profile completion")

                        self.removeLoadingAnimation(loadingAnimation)

                        let patientInfoVC = patientInfo()

                        // Set the delegate to SceneDelegate to handle navigation after profile completion

                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {

                            patientInfoVC.delegate = sceneDelegate

                        }

                        let nav = UINavigationController(rootViewController: patientInfoVC)

                        nav.modalPresentationStyle = .pageSheet  // Change from .fullScreen to .pageSheet

                        self.present(nav, animated: true)

                    }

                } else {

                    // New user, generate unique patient ID and save profile

                    self.generateUniquePatientID { patientUID in

                        guard let patientUID = patientUID else {

                            self.removeLoadingAnimation(loadingAnimation)

                            print("Failed to generate unique Patient ID.")

                            self.showAlert(message: "Unable to create profile. Please try again.")

                            return

                        }



                        // Initial data structure

                        let initialData: [String: Any] = [

                            "email": email,

                            "patientUID": patientUID,

                            "firstName": "",

                            "lastName": "",

                            "dateOfBirth": "",

                            "sex": "",

                            "bloodGroup": "",

                            "stage": "",

                            "profileImageURL": "",

                            "familyMembers": [],

                            "type": "patient",

                        ]



                        // Save the initial user profile to Firestore

                        db.collection("users").document(userId).setData(initialData) { error in

                            if let error = error {

                                self.removeLoadingAnimation(loadingAnimation)

                                print("Error saving initial user profile: \(error.localizedDescription)")

                                self.showAlert(message: "Failed to create profile. Please try again.")

                            } else {

                                print("New user profile created successfully")

                                self.removeLoadingAnimation(loadingAnimation)

                                let patientInfoVC = patientInfo()

                                // Set the delegate to SceneDelegate to handle navigation after profile completion

                                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {

                                    patientInfoVC.delegate = sceneDelegate

                                }

                                let nav = UINavigationController(rootViewController: patientInfoVC)

                                nav.modalPresentationStyle = .pageSheet  // Change from .fullScreen to .pageSheet

                                self.present(nav, animated: true)

                            }

                        }

                    }

                }

            }

        }

        

        private func generateUniquePatientID(completion: @escaping (String?) -> Void) {

            let db = Firestore.firestore()

            

            // Generate a random 6-digit number

            let randomNum = Int.random(in: 100000...999999)

            let patientUID = "P\(randomNum)"

            

            // Check if this ID already exists

            db.collection("users").whereField("patientUID", isEqualTo: patientUID).getDocuments { snapshot, error in

                if let error = error {

                    print("Error checking for existing patient ID: \(error.localizedDescription)")

                    completion(nil)

                    return

                }

                

                if let snapshot = snapshot, snapshot.isEmpty {

                    // ID is unique, return it

                    completion(patientUID)

                } else {

                    // ID already exists, try again

                    self.generateUniquePatientID(completion: completion)

                }

            }

        }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Add subviews
        [logoImageView, titleLabel, emailField, passwordField,
//         rememberMeButton,
         forgotPasswordButton, loginButton, dividerLabel, socialButtonsStack,
         signupButton, signupPromptLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Setup social buttons stack
        socialButtonsStack.addArrangedSubview(googleButton)
        socialButtonsStack.addArrangedSubview(appleButton)

        // Setup constraints
        NSLayoutConstraint.activate(
            [
                logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                logoImageView.widthAnchor.constraint(equalToConstant: 100),
                logoImageView.heightAnchor.constraint(equalToConstant: 100),

                titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

                emailField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
                emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                emailField.heightAnchor.constraint(equalToConstant: Constants.ButtonStyle.DefaultButtonHeight),

                passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
                passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                passwordField.heightAnchor.constraint(equalToConstant: Constants.ButtonStyle.DefaultButtonHeight),

                forgotPasswordButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 16),
                forgotPasswordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

                loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 15),
                loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                loginButton.heightAnchor.constraint(equalToConstant: Constants.ButtonStyle.DefaultButtonHeight - 6),

                dividerLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 30),
                dividerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                // For the social buttons stack (already correctly centered)
                socialButtonsStack.topAnchor.constraint(equalTo: dividerLabel.bottomAnchor, constant: 10),
                socialButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                socialButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                socialButtonsStack.heightAnchor.constraint(equalToConstant: 116), // 50 * 2 + 16 spacing

                // For the signup section at the bottom
                signupButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                signupPromptLabel.centerYAnchor.constraint(equalTo: signupButton.centerYAnchor),
                signupPromptLabel.leadingAnchor.constraint(equalTo: signupButton.trailingAnchor, constant: 4),

                // Add this to create a horizontal stack effect that's centered
                signupButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -2),
            ]
        )

        // Add targets
//        rememberMeButton.addTarget(self, action: #selector(toggleRememberMe), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signupTapped), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(googleLoginTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        passwordField.isSecureTextEntry.toggle()
        let imageName = passwordField.isSecureTextEntry ? "eye.slash" : "eye"
        sender.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

#Preview{
    PatientLoginViewController()
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
