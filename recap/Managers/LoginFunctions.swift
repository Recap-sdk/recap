//
//  LoginFunctions.swift
//  recap
//
//  Created by Diptayan Jash on 15/12/24.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UIKit
import Lottie
import AuthenticationServices
import CryptoKit

extension PatientLoginViewController {
//    @objc func rememberMeTapped() {
//        rememberMeButton.isSelected.toggle()
//    }

    @objc func loginTapped() {
        print("Login tapped")
        
        // Validate input fields
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(message: "Please enter both email and password.")
            return
        }
        
        // Validate email format
        if !isValidEmail(email) {
            showAlert(message: "Please enter a valid email address.")
            return
        }
        
        // Show loading animation
        let loadingAnimation = showLoadingAnimation()
        
        // Sign in with Firebase Auth
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                // Remove loading animation if there's an error
                self.removeLoadingAnimation(loadingAnimation)
                print("Login Error: \(error.localizedDescription)")
                self.showAlert(message: "Login failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                // Remove loading animation if no user is found
                self.removeLoadingAnimation(loadingAnimation)
                self.showAlert(message: "Login unsuccessful. Please try again.")
                return
            }
            
            // Store user ID in UserDefaults
            let userId = user.uid
            UserDefaults.standard.set(userId, forKey: Constants.UserDefaultsKeys.verifiedUserDocID)
            UserDefaults.standard.set(email, forKey: "userEmail")
            
            // Use the existing fetchOrCreateUserProfile function for consistency
            self.fetchOrCreateUserProfile(userId: userId, email: email, loadingAnimation: loadingAnimation)
        }
    }

    @objc func signupTapped() {
        // Create and present the signup view controller
        let signupVC = PatientSignupViewController()
        let nav = UINavigationController(rootViewController: signupVC)
        // Present the signup view controller
        present(nav, animated: true)
    }

    // Helper method for email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    @objc func googleLoginTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase client ID not found")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Show loading animation immediately before presenting Google Sign-In
        let loadingAnimation = self.showLoadingAnimation()
        loadingAnimation.isHidden = true // Initially hide it

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }

            // Make the loading animation visible once Google Sign-In screen dismisses
            loadingAnimation.isHidden = false

            if let error = error {
                // Remove loading animation if there's an error
                self.removeLoadingAnimation(loadingAnimation)
                print("Google Sign-In Error: \(error.localizedDescription)")
                self.showAlert(message: "Google Sign-In failed. Please try again.")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                // Remove loading animation if user retrieval fails
                self.removeLoadingAnimation(loadingAnimation)
                print("Failed to retrieve Google user")
                self.showAlert(message: "Unable to retrieve user information.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [weak self] authResult, authError in
                guard let self = self else { return }

                if let authError = authError {
                    // Remove loading animation if there's an authentication error
                    self.removeLoadingAnimation(loadingAnimation)
                    print("Firebase Authentication Error: \(authError.localizedDescription)")
                    self.showAlert(message: "Authentication failed. Please try again.")
                    return
                }

                guard let firebaseUser = authResult?.user else {
                    // Remove loading animation if no user is found
                    self.removeLoadingAnimation(loadingAnimation)
                    self.showAlert(message: "Login unsuccessful. Please try again.")
                    return
                }

                let userId = firebaseUser.uid
                UserDefaults.standard.set(userId, forKey: Constants.UserDefaultsKeys.verifiedUserDocID)
                self.fetchOrCreateUserProfile(userId: userId, email: firebaseUser.email ?? "", loadingAnimation: loadingAnimation)
            }
        }
    }

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
                generateUniquePatientID { patientUID in
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

    private func fetchUserProfileAndNavigate(userId: String) {
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                self.showAlert(message: "Failed to fetch user profile.")
                return
            }

            if let document = document, document.exists, let userData = document.data() {
                print("User profile fetched successfully: \(userData)")
                
                // Check if profile is complete by verifying required fields
                let requiredFields = ["firstName", "lastName", "dateOfBirth", "sex", "bloodGroup", "stage"]
                let isProfileComplete = requiredFields.allSatisfy { field in
                    guard let value = userData[field] as? String else { return false }
                    return !value.isEmpty
                }
                
                if isProfileComplete {
                    // Profile is complete, navigate to main view
                    UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isPatientLoggedIn)
                    UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.hasPatientCompletedProfile)
                    UserDefaults.standard.synchronize()
                    
                    UserDefaultsStorageProfile.shared.saveProfile(details: userData, image: nil) { [weak self] success in
                        if success {
                            let mainVC = TabbarViewController()
                            self?.navigationController?.setViewControllers([mainVC], animated: true)
                        } else {
                            print("Failed to save profile")
                            self?.showAlert(message: "Failed to save user profile locally.")
                        }
                    }
                } else {
                    // Profile exists but is incomplete, navigate to profile completion
                    print("User profile is incomplete, navigating to profile completion")
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
                print("User profile not found. Redirecting to profile setup.")
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

    @objc func appleLoginTapped() {
        print("Apple login tapped")
        
        // Show loading animation immediately before presenting Apple Sign-In
        let loadingAnimation = self.showLoadingAnimation()
        loadingAnimation.isHidden = true // Initially hide it
        
        // Start the Apple Sign In flow
        startSignInWithAppleFlow()
    }
    
    // MARK: - Apple Sign In
    private func startSignInWithAppleFlow() {
        print("Starting Apple Sign In flow")
        
        // Generate a new nonce for each sign-in attempt
        let nonce = randomNonceString()
        self.currentNonce = nonce
        print("Generated nonce: \(nonce)")
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        print("Created Apple ID request with nonce hash: \(sha256(nonce))")
        
        // Create an authorization controller with the request
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        // Set delegate and presentation context provider
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        
        // Perform the request
        print("Performing Apple Sign-In request")
        authorizationController.performRequests()
        print("Apple Sign-In request performed successfully")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()

            // Clear user session and local storage
            UserDefaults.standard
                .removeObject(
                    forKey: Constants.UserDefaultsKeys.hasPatientCompletedProfile
                )
            UserDefaults.standard
                .removeObject(
                    forKey: Constants.UserDefaultsKeys.isPatientLoggedIn
                )
            UserDefaultsStorageProfile.shared.clearProfile()

            // Animate the swipe down effect
            guard let window = UIApplication.shared.windows.first else { return }

            // Create the welcome view controller
            let welcomeVC = WelcomeViewController()
            let navigationController = UINavigationController(rootViewController: welcomeVC)

            // Set the initial position of the new view controller off-screen
            navigationController.view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()

            // Animate the transition
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)
                navigationController.view.frame = window.bounds
            }) { _ in
                window.rootViewController = navigationController
            }
        } catch {
            // Handle sign-out error
            print("Error signing out: \(error.localizedDescription)")
            showAlert(message: "Failed to log out. Please try again.")
        }
    }

    // MARK: - ASAuthorizationControllerDelegate
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        print("Apple Sign-In authorization completed successfully")
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                print("ERROR: No nonce found for Apple Sign-In")
                showAlert(message: "Apple Sign-In failed: Invalid state. Please try again.")
                return
            }
            
            // Clear current nonce after retrieving it to prevent reuse
            currentNonce = nil
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("ERROR: No identity token received from Apple")
                showAlert(message: "Apple Sign-In failed: Unable to fetch identity token.")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("ERROR: Unable to convert identity token to string")
                showAlert(message: "Apple Sign-In failed: Unable to process identity token.")
                return
            }
            
            print("Successfully obtained Apple ID token")
            
            // Get user information
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            print("User ID: \(userIdentifier)")
            print("Email: \(email ?? "Not provided")")
            print("Full Name: \(fullName?.givenName ?? "Not provided") \(fullName?.familyName ?? "")")
            
            // Create Firebase credential
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            print("Created Firebase credential with Apple ID token")
            
            // Show loading animation
            let loadingAnimation = self.showLoadingAnimation()
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let self = self else { return }
                
                // Hide loading animation
                loadingAnimation.isHidden = true
                
                if let error = error {
                    print("ERROR: Firebase sign-in failed: \(error.localizedDescription)")
                    self.showAlert(message: "Apple Sign-In failed: \(error.localizedDescription)")
                    return
                }
                
                guard let authResult = authResult else {
                    print("ERROR: Firebase auth result is nil")
                    self.showAlert(message: "Apple Sign-In failed: Authentication result is missing.")
                    return
                }
                
                print("Firebase sign-in successful for user: \(authResult.user.uid)")
                
                // Check if this is a new user
                let isNewUser = authResult.additionalUserInfo?.isNewUser ?? false
                print("Is new user: \(isNewUser)")
                
                // Store user ID in UserDefaults
                let userId = authResult.user.uid
                UserDefaults.standard.set(userId, forKey: Constants.UserDefaultsKeys.verifiedUserDocID)
                UserDefaults.standard.set(email ?? authResult.user.email ?? "", forKey: "userEmail")
                
                // Use the existing fetchOrCreateUserProfile function for consistency
                self.fetchOrCreateUserProfile(userId: userId, email: email ?? authResult.user.email ?? "", loadingAnimation: loadingAnimation)
            }
        } else {
            print("ERROR: Authorization credential is not an Apple ID credential")
            showAlert(message: "Apple Sign-In failed: Invalid credential type.")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("ERROR: Apple Sign-In authorization failed: \(error.localizedDescription)")
        
        // Clear nonce when authorization fails to prevent stale nonce
        currentNonce = nil
        
        // Check for specific error types
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                print("User canceled the Apple Sign-In process")
                // Don't show an alert for user cancellation
            case .failed:
                print("Apple Sign-In failed: \(authError.localizedDescription)")
                showAlert(message: "Apple Sign-In failed. Please try again.")
            case .invalidResponse:
                print("Apple Sign-In received an invalid response")
                showAlert(message: "Apple Sign-In received an invalid response. Please try again.")
            case .notHandled:
                print("Apple Sign-In request was not handled")
                showAlert(message: "Apple Sign-In request was not handled. Please try again.")
            case .unknown:
                print("Unknown error during Apple Sign-In: \(authError.localizedDescription)")
                showAlert(message: "An unknown error occurred during Apple Sign-In. Please try again.")
            @unknown default:
                print("Unhandled Apple Sign-In error: \(authError.localizedDescription)")
                showAlert(message: "An unexpected error occurred during Apple Sign-In. Please try again.")
            }
        } else {
            // Handle other types of errors
            print("Non-ASAuthorizationError during Apple Sign-In: \(error.localizedDescription)")
            showAlert(message: "Apple Sign-In failed: \(error.localizedDescription)")
        }
    }
}
