//
//  FamilyLoginFunctions.swift
//  recap
//
//  Created by user@47 on 29/01/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UIKit

extension FamilyLoginViewController {
    
    @objc func rememberMeTapped() {
        rememberMeButton.isSelected.toggle()
    }

    @objc func loginTapped() {
        print("Login tapped")

        guard let loginVC = self as? FamilyLoginViewController else { return }

        let patientEmail = loginVC.emailField.text ?? "" // Patient's email
        let enteredPassword = loginVC.passwordField.text ?? "" // Family member's password

        let db = Firestore.firestore()

        // 🔹 Step 1: Fetch Patient's UID
        db.collection("users").whereField("email", isEqualTo: patientEmail).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching patient UID: \(error.localizedDescription)")
                loginVC.showAlert(message: "Patient not found.")
                return
            }

            guard let document = querySnapshot?.documents.first else {
                loginVC.showAlert(message: "Patient not found.")
                return
            }

            let patientUID = document.documentID

            // 🔹 Step 2: Fetch Family Members
            db.collection("users").document(patientUID).collection("family_members").getDocuments { (familySnapshot, error) in
                if let error = error {
                    print("Error fetching family members: \(error.localizedDescription)")
                    loginVC.showAlert(message: "Unable to retrieve family details.")
                    return
                }

                guard let familyDocs = familySnapshot?.documents, !familyDocs.isEmpty else {
                    loginVC.showAlert(message: "No family members found.")
                    return
                }

                var matchedFamilyMember: [String: Any]? = nil

                // 🔹 Step 3: Match Password with Family Members
                for familyDoc in familyDocs {
                    let familyData = familyDoc.data() // No optional binding needed
                    if let storedPassword = familyData["password"] as? String {
                        if storedPassword == enteredPassword {
                            matchedFamilyMember = familyData
                            break
                        }
                    }
                }


                if let familyMember = matchedFamilyMember {
                    print("Family member authenticated: \(familyMember)")

                    let reportsVC = FamilyViewController()

                    if let navController = self.navigationController {
                        navController.pushViewController(reportsVC, animated: true)
                    } else {
                        self.present(reportsVC, animated: true)
                    }
                } else {
                    self.showAlert(message: "Incorrect password. Please try again.")
                }

            }
        }
    }


    @objc func signupTapped() {
        let signupVC = FamilySignupViewController() // Replace with your sign-up VC
        navigationController?.pushViewController(signupVC, animated: true)
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

            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            // Authenticate with Firebase
            Auth.auth().signIn(with: credential) { [weak self] authResult, authError in
                guard let self = self else { return }

                // Handle authentication error
                if let authError = authError {
                    print("Firebase Authentication Error: \(authError.localizedDescription)")
                    self.showAlert(message: "Authentication failed. Please try again.")
                    return
                }

                // Successfully authenticated
                guard let firebaseUser = authResult?.user else {
                    self.showAlert(message: "Login unsuccessful. Please try again.")
                    return
                }

                // Check if the user profile exists in Firestore
                let db = Firestore.firestore()
                let userId = firebaseUser.uid

                // Prepare user profile
                let userProfile: [String: Any] = [
                    "uid": firebaseUser.uid,
                    "firstName": firebaseUser.displayName ?? "",
                    "email": firebaseUser.email ?? "",
                    "profileImageURL": firebaseUser.photoURL?.absoluteString ?? "",
                    "hasCompletedProfile": false,
                ]

                // Save user profile to UserDefaults
                UserDefaultsStorageProfile.shared.saveProfile(details: userProfile, image: nil) { [weak self] _ in
                    guard let self = self else { return }

                    // Check if the user profile exists in Firestore
                    db.collection("users").document(userId).getDocument { document, error in
                        if let error = error {
                            print("Error fetching user profile: \(error.localizedDescription)")
                            self.showAlert(message: "Failed to fetch user profile.")
                            return
                        }

                        if let document = document, document.exists {
                            // User profile exists, navigate to FamilyViewController
                            let familyVC = FamilyViewController() // Replace with your FamilyViewController
                            self.navigationController?.pushViewController(familyVC, animated: true)
                        } else {
                            // Navigate to familyInfo to create a profile
                            let familyInfoVC = familyInfo() // Replace with your family info VC
                            let nav = UINavigationController(rootViewController: familyInfoVC)
                            self.present(nav, animated: true)
                        }
                    }
                }
            }
        }
    }

    @objc func appleLoginTapped() {
        print("Apple login tapped")
        
        let familyViewController = TabbarFamilyViewController()
        
        // Present as a full-screen page
        familyViewController.modalPresentationStyle = .fullScreen
        
        present(familyViewController, animated: true, completion: nil)
    }

    
    @objc func logoutTapped() {
        do {
            // Sign out from Firebase Authentication
            try Auth.auth().signOut()

            // Sign out from Google Sign-In
            GIDSignIn.sharedInstance.signOut()

            // Clear user session and local storage
            UserDefaults.standard.removeObject(forKey: "hasCompletedProfile")
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
                // Move the current view controller off-screen
                self.view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)

                // Move the new view controller into view
                navigationController.view.frame = window.bounds
            }) { _ in
                // After the animation completes, set the root view controller to the new one
                window.rootViewController = navigationController
            }
        } catch {
            // Handle sign-out error
            print("Error signing out: \(error.localizedDescription)")
            showAlert(message: "Failed to log out. Please try again.")
        }
    }
}
