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

extension PatientLoginViewController {
//    @objc func rememberMeTapped() {
//        rememberMeButton.isSelected.toggle()
//    }

    @objc func loginTapped() {
        print("Login tapped")

        guard let loginVC = self as? PatientLoginViewController else { return }

        let email = loginVC.emailField.text ?? ""
        let password = loginVC.passwordField.text ?? ""

        Auth.auth().signIn(withEmail: email, password: password) { [weak loginVC] authResult, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                loginVC?.showAlert(message: "Invalid email or password.")
                return
            }

            guard let user = authResult?.user else { return }
            let userId = user.uid // Get the patient ID from Firebase session

            FirebaseManager.shared.fetchUserDetails(userId: userId) { userDetails, error in
                if let error = error {
                    print("Error fetching user details: \(error.localizedDescription)")
                    return
                }

                if let userDetails = userDetails {
                    UserDefaultsStorageProfile.shared.saveProfile(details: userDetails.dictionary, image: nil) { [weak loginVC] success in
                        if success {
                            // Fetch family members
                            FirebaseManager.shared.fetchFamilyMembers(for: userId) { familyMembers, _ in
                                if let familyMembers = familyMembers {
                                    // Handle family members as needed
                                }
                            }
                            let mainVC = TabbarViewController()
                            loginVC?.navigationController?.setViewControllers([mainVC], animated: true)
                        } else {
                            print("Failed to save profile")
                        }
                    }
                } else {
                    print("User profile not found.")
                    loginVC?.showAlert(message: "User profile not found.")
                }
            }
        }
    }

    @objc func signupTapped() {
//        let signupVC = PatientSignupViewController()
//        navigationController?.pushViewController(signupVC, animated: true)

        let signupVC = patientInfo()
        let nav = UINavigationController(rootViewController: signupVC)
        present(nav, animated: true)
    }

    @objc func googleLoginTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Firebase client ID not found")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Google Sign-In Error: \(error.localizedDescription)")
                self.showAlert(message: "Google Sign-In failed. Please try again.")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to retrieve Google user")
                self.showAlert(message: "Unable to retrieve user information.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { [weak self] authResult, authError in
                guard let self = self else { return }

                if let authError = authError {
                    print("Firebase Authentication Error: \(authError.localizedDescription)")
                    self.showAlert(message: "Authentication failed. Please try again.")
                    return
                }

                guard let firebaseUser = authResult?.user else {
                    self.showAlert(message: "Login unsuccessful. Please try again.")
                    return
                }

                let userId = firebaseUser.uid
                self.fetchOrCreateUserProfile(userId: userId, email: firebaseUser.email ?? "")
            }
        }
    }

    private func fetchOrCreateUserProfile(userId: String, email: String) {
        UserDefaults.standard
            .set(true, forKey: Constants.UserDefaultsKeys.isPatientLoggedIn)
        UserDefaults.standard.synchronize()
        let db = Firestore.firestore()

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                self.showAlert(message: "Failed to fetch user profile.")
                return
            }

            if let document = document, document.exists {
                // Existing user profile found, navigate to main view
                print("User profile fetched successfully")
                let tabBarVC = TabbarViewController()
                self.navigationController?.setViewControllers([tabBarVC], animated: true)
            } else {
                // New user, generate unique patient ID and save profile
                generateUniquePatientID { patientUID in
                    guard let patientUID = patientUID else {
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
                            print("Error saving initial user profile: \(error.localizedDescription)")
                            self.showAlert(message: "Failed to create profile. Please try again.")
                        } else {
                            print("New user profile created successfully")
                            let patientInfoVC = patientInfo()
                            let nav = UINavigationController(rootViewController: patientInfoVC)
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
                print("User profile not found. Redirecting to profile setup.")
                let patientInfoVC = patientInfo()
                let nav = UINavigationController(rootViewController: patientInfoVC)
                self.present(nav, animated: true)
            }
        }
    }

    @objc func appleLoginTapped() {
        print("Apple login tapped")
        // Implement Apple login logic here
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
}
