import Firebase
import FirebaseAuth
import FirebaseFirestore
import Lottie
import UIKit

class PatientSignupViewController: UIViewController, UITextFieldDelegate {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "recapLogo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create Account"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emailIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "envelope")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()

    private let passwordContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let passwordIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password (min. 6 characters)"
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let emailErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let passwordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let confirmPasswordContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let confirmPasswordIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "lock.shield")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let confirmPasswordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let confirmPasswordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let confirmPasswordErrorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
        button
            .setTitleColor(
                Constants.ButtonStyle.DefaultButtonTextColor,
                for: .normal
            )
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Already have an account? Log in", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        let Dismisskeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Dismisskeyboard)

        emailField.delegate = self
        passwordField.delegate = self
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // Scroll to active text field if needed
        var visibleRect = view.frame
        visibleRect.size.height -= keyboardSize.height

        if let activeField = [emailField, passwordField].first(where: { $0.isFirstResponder }) {
            let activeRect = activeField.convert(activeField.bounds, to: scrollView)
            if !visibleRect.contains(activeRect.origin) {
                scrollView.scrollRectToVisible(activeRect, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupUI() {
        view.backgroundColor = .white

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)

        contentView.addSubview(emailContainerView)
        emailContainerView.addSubview(emailIconView)
        emailContainerView.addSubview(emailField)
        contentView.addSubview(emailErrorLabel)

        contentView.addSubview(passwordContainerView)
        passwordContainerView.addSubview(passwordIconView)
        passwordContainerView.addSubview(passwordField)
        passwordContainerView.addSubview(passwordToggleButton)
        contentView.addSubview(passwordErrorLabel)

        contentView.addSubview(confirmPasswordContainerView)
        confirmPasswordContainerView.addSubview(confirmPasswordIconView)
        confirmPasswordContainerView.addSubview(confirmPasswordField)
        confirmPasswordContainerView.addSubview(confirmPasswordToggleButton)
        contentView.addSubview(confirmPasswordErrorLabel)

        contentView.addSubview(continueButton)
        contentView.addSubview(backButton)

        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            // Make contentView at least as tall as the view to allow scrolling when keyboard appears
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor, multiplier: 0.9),

            // Logo
            logoImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),

            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            // Email Container
            emailContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            emailContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            emailContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emailContainerView.heightAnchor.constraint(equalToConstant: 56),

            // Email Icon
            emailIconView.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 12),
            emailIconView.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailIconView.widthAnchor.constraint(equalToConstant: 24),
            emailIconView.heightAnchor.constraint(equalToConstant: 24),

            // Email Field
            emailField.leadingAnchor.constraint(equalTo: emailIconView.trailingAnchor, constant: 12),
            emailField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -12),
            emailField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailField.heightAnchor.constraint(equalToConstant: 40),

            // Email Error Label
            emailErrorLabel.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 4),
            emailErrorLabel.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 12),
            emailErrorLabel.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -12),

            // Password Container
            passwordContainerView.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 24),
            passwordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 56),

            // Password Icon
            passwordIconView.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 12),
            passwordIconView.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordIconView.widthAnchor.constraint(equalToConstant: 24),
            passwordIconView.heightAnchor.constraint(equalToConstant: 24),

            // Password Field
            passwordField.leadingAnchor.constraint(equalTo: passwordIconView.trailingAnchor, constant: 12),
            passwordField.trailingAnchor.constraint(equalTo: passwordToggleButton.leadingAnchor, constant: -8),
            passwordField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordField.heightAnchor.constraint(equalToConstant: 40),

            // Password Toggle Button
            passwordToggleButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -12),
            passwordToggleButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            passwordToggleButton.heightAnchor.constraint(equalToConstant: 24),

            // Password Error Label
            passwordErrorLabel.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 4),
            passwordErrorLabel.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 12),
            passwordErrorLabel.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -12),

            // Confirm Password Container
            confirmPasswordContainerView.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 24),
            confirmPasswordContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            confirmPasswordContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            confirmPasswordContainerView.heightAnchor.constraint(equalToConstant: 56),

            // Confirm Password Icon
            confirmPasswordIconView.leadingAnchor.constraint(equalTo: confirmPasswordContainerView.leadingAnchor, constant: 12),
            confirmPasswordIconView.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            confirmPasswordIconView.widthAnchor.constraint(equalToConstant: 24),
            confirmPasswordIconView.heightAnchor.constraint(equalToConstant: 24),

            // Confirm Password Field
            confirmPasswordField.leadingAnchor.constraint(equalTo: confirmPasswordIconView.trailingAnchor, constant: 12),
            confirmPasswordField.trailingAnchor.constraint(equalTo: confirmPasswordToggleButton.leadingAnchor, constant: -8),
            confirmPasswordField.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 40),

            // Confirm Password Toggle Button
            confirmPasswordToggleButton.trailingAnchor.constraint(equalTo: confirmPasswordContainerView.trailingAnchor, constant: -12),
            confirmPasswordToggleButton.centerYAnchor.constraint(equalTo: confirmPasswordContainerView.centerYAnchor),
            confirmPasswordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            confirmPasswordToggleButton.heightAnchor.constraint(equalToConstant: 24),

            // Confirm Password Error Label
            confirmPasswordErrorLabel.topAnchor.constraint(equalTo: confirmPasswordContainerView.bottomAnchor, constant: 4),
            confirmPasswordErrorLabel.leadingAnchor.constraint(equalTo: confirmPasswordContainerView.leadingAnchor, constant: 12),
            confirmPasswordErrorLabel.trailingAnchor.constraint(equalTo: confirmPasswordContainerView.trailingAnchor, constant: -12),

            // Continue Button
            continueButton.topAnchor.constraint(equalTo: confirmPasswordContainerView.bottomAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 56),

            // Back Button
            backButton.topAnchor.constraint(equalTo: continueButton.bottomAnchor, constant: 20),
            backButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)

        // Add real-time validation
        emailField.addTarget(self, action: #selector(validateEmailField), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(validatePasswordField), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(validateConfirmPasswordField), for: .editingChanged)
    }

    // MARK: - Validation

    @objc private func validateEmailField() {
        if let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
            if isValidEmail(email) {
                emailErrorLabel.isHidden = true
                emailContainerView.layer.borderWidth = 0
            } else {
                emailErrorLabel.text = "Please enter a valid email address"
                emailErrorLabel.isHidden = false
                emailContainerView.layer.borderWidth = 1
                emailContainerView.layer.borderColor = UIColor.systemRed.cgColor
            }
        } else {
            emailErrorLabel.isHidden = true
            emailContainerView.layer.borderWidth = 0
        }
    }

    @objc private func validatePasswordField() {
        if let password = passwordField.text, !password.isEmpty {
            if password.count < 6 {
                passwordErrorLabel.text = "Password must be at least 6 characters"
                passwordErrorLabel.isHidden = false
                passwordContainerView.layer.borderWidth = 1
                passwordContainerView.layer.borderColor = UIColor.systemRed.cgColor
            } else {
                passwordErrorLabel.isHidden = true
                passwordContainerView.layer.borderWidth = 0
            }

            // Also validate confirm password when password changes
            validateConfirmPasswordField()
        } else {
            passwordErrorLabel.isHidden = true
            passwordContainerView.layer.borderWidth = 0
        }
    }

    @objc private func validateConfirmPasswordField() {
        guard let password = passwordField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordField.text, !confirmPassword.isEmpty else {
            confirmPasswordErrorLabel.isHidden = true
            confirmPasswordContainerView.layer.borderWidth = 0
            return
        }

        if password != confirmPassword {
            confirmPasswordErrorLabel.text = "Passwords do not match"
            confirmPasswordErrorLabel.isHidden = false
            confirmPasswordContainerView.layer.borderWidth = 1
            confirmPasswordContainerView.layer.borderColor = UIColor.systemRed.cgColor
        } else {
            confirmPasswordErrorLabel.isHidden = true
            confirmPasswordContainerView.layer.borderWidth = 0
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordField.isSecureTextEntry = !passwordField.isSecureTextEntry

        if passwordField.isSecureTextEntry {
            passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            passwordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }

    @objc private func toggleConfirmPasswordVisibility() {
        confirmPasswordField.isSecureTextEntry = !confirmPasswordField.isSecureTextEntry

        // Update the button image based on password visibility
        if confirmPasswordField.isSecureTextEntry {
            confirmPasswordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            confirmPasswordToggleButton.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }

    @objc private func continueButtonTapped() {
        let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }

        if !isValidEmail(email) {
            emailErrorLabel.text = "Please enter a valid email address"
            emailErrorLabel.isHidden = false
            emailContainerView.layer.borderWidth = 1
            emailContainerView.layer.borderColor = UIColor.systemRed.cgColor
            return
        }

        // Validate password strength
        if password.count < 6 {
            passwordErrorLabel.text = "Password must be at least 6 characters"
            passwordErrorLabel.isHidden = false
            passwordContainerView.layer.borderWidth = 1
            passwordContainerView.layer.borderColor = UIColor.systemRed.cgColor
            return
        }

        // Validate passwords match
        if password != confirmPassword {
            confirmPasswordErrorLabel.text = "Passwords do not match"
            confirmPasswordErrorLabel.isHidden = false
            confirmPasswordContainerView.layer.borderWidth = 1
            confirmPasswordContainerView.layer.borderColor = UIColor.systemRed.cgColor
            return
        }

        // Show loading animation
        let loadingAnimation = showLoadingAnimation()

        // Create the user with Firebase Auth
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                // Remove loading animation
                self.removeLoadingAnimation(loadingAnimation)
                print("Error creating user: \(error.localizedDescription)")
                self.showAlert(message: "Failed to create account: \(error.localizedDescription)")
                return
            }

            guard let user = authResult?.user else {
                // Remove loading animation
                self.removeLoadingAnimation(loadingAnimation)
                self.showAlert(message: "Failed to create user account.")
                return
            }

            // Store user ID in UserDefaults
            let userId = user.uid
            UserDefaults.standard.set(userId, forKey: Constants.UserDefaultsKeys.verifiedUserDocID)
            UserDefaults.standard.set(email, forKey: "userEmail")

            // Use the existing generateUniquePatientID function
            generateUniquePatientID { patientUID in
                guard let patientUID = patientUID else {
                    self.removeLoadingAnimation(loadingAnimation)
                    print("Failed to generate unique Patient ID.")
                    self.showAlert(message: "Unable to create profile. Please try again.")
                    return
                }

                // Initial data structure - same as in Google sign-in flow
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
                let db = Firestore.firestore()
                db.collection("users").document(userId).setData(initialData) { error in
                    // Remove loading animation
                    self.removeLoadingAnimation(loadingAnimation)

                    if let error = error {
                        print("Error saving initial user profile: \(error.localizedDescription)")
                        self.showAlert(message: "Failed to create profile. Please try again.")
                    } else {
                        print("New user profile created successfully")

                        // Navigate to patient info screen to complete profile
                        let patientInfoVC = patientInfo()
                        // Set the delegate to SceneDelegate to handle navigation after profile completion
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            patientInfoVC.delegate = sceneDelegate
                        }
                        let nav = UINavigationController(rootViewController: patientInfoVC)
                        nav.modalPresentationStyle = .pageSheet
                        self.present(nav, animated: true)
                    }
                }
            }
        }
    }

    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    // MARK: - Helpers

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
