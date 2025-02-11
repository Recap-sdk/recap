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
    @objc func verifyPatientUID() {
        print("Verify Button tapped")

        // Animate the verify button to indicate processing
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.color = .white
        verifyButton.setTitle("", for: .normal)
        verifyButton.addSubview(spinner)
        spinner.center = CGPoint(x: verifyButton.bounds.midX, y: verifyButton.bounds.midY)

        guard let verifyUID = self as? FamilyLoginViewController else { return }

        let patientUID = verifyUID.patientUIDField.text ?? ""
        print("Patient UID entered: \(patientUID)") // Log the entered patient UID

        let db = Firestore.firestore()

        db.collection("users").getDocuments { usersSnapshot, error in
            spinner.stopAnimating() // Stop the spinner once request completes
            self.verifyButton.setTitle("Verify", for: .normal)
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                verifyUID.showAlert(message: "Unable to retrieve user details.")
                return
            }

            guard let userDocs = usersSnapshot?.documents, !userDocs.isEmpty else {
                self.animateShake(for: self.patientUIDField)
                verifyUID.showAlert(message: "No users found.")
                return
            }

            var patientUIDFound = false
            for userDoc in userDocs {
                let userData = userDoc.data()
                // Log the fetched user data for debugging purposes
                print("Fetched user data: \(userData)")

                // Check if the patient UID exists and matches
                if let storedUID = userData["patientUID"] as? String, storedUID == patientUID {
                    print("Patient UID verified successfully")

                    // Enable the email and password fields
                    verifyUID.emailField.isEnabled = true
                    verifyUID.passwordField.isEnabled = true

                    // Store the document ID in UserDefaults or similar
                    UserDefaults.standard.set(userDoc.documentID, forKey: "verifiedUserDocID")
                    print("Verified user document ID: \(userDoc.documentID)")

                    // Button success animation
                    UIView.animate(withDuration: 0.3) {
                        self.verifyButton.setTitle("Verified", for: .normal)
                        self.verifyButton.backgroundColor = .systemGreen
                    }

                    patientUIDFound = true
                    break
                }
            }

            if !patientUIDFound {
                verifyUID.showAlert(message: "Patient UID does not match. Please try again.")
            }
        }
    }

    @objc func loginTapped() {
        print("Login tapped")

        guard let loginVC = self as? FamilyLoginViewController else { return }

        guard let userDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") else {
            print("No user document found. Please verify UID first.")
            loginVC.showAlert(message: "Please verify patient UID first.")
            return
        }

        let enteredEmail = loginVC.emailField.text ?? ""
        let enteredPassword = loginVC.passwordField.text ?? ""

        print("Email entered: \(enteredEmail)")
        print("Password entered: \(enteredPassword)")

        let db = Firestore.firestore()

        db.collection("users").document(userDocID).collection("family_members").getDocuments { familySnapshot, error in
            if let error = error {
                print("Error fetching family members: \(error.localizedDescription)")
                loginVC.showAlert(message: "Unable to retrieve family details.")
                return
            }

            guard let familyDocs = familySnapshot?.documents, !familyDocs.isEmpty else {
                loginVC.showAlert(message: "No family members found.")
                return
            }

            var matchedFamilyMember: [String: Any]?

            for familyDoc in familyDocs {
                let familyData = familyDoc.data()
                print("Fetched family member data: \(familyData)")

                if let storedPassword = familyData["password"] as? String, storedPassword == enteredPassword,
                   let email = familyData["email"] as? String, email == enteredEmail {
                    matchedFamilyMember = familyData
                    break
                }
            }

            if let matchedMember = matchedFamilyMember {
                print("Family member authenticated: \(matchedMember)")

                // Store family member details
                UserDefaults.standard.set(matchedMember, forKey: "familyMemberDetails")

                // Store the image URL for profile use
                if let imageUrl = matchedMember["imageURL"] as? String {
                    UserDefaults.standard.set(imageUrl, forKey: Constants.UserDefaultsKeys.familyMemberImageURL)
                }

                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn)
                UserDefaults.standard.synchronize()

                db.collection("users").document(userDocID).getDocument { document, error in
                    if let error = error {
                        print("Error fetching patient details: \(error.localizedDescription)")
                        return
                    }

                    guard let document = document, document.exists else {
                        print("Patient document not found.")
                        return
                    }

                    let userData = document.data() ?? [:]
                    print("Fetched user data for patient: \(userData)")

                    // Store patient details
                    UserDefaults.standard.set(userData, forKey: "patientDetails")

                    // Navigate to FamilyViewController
                    DispatchQueue.main.async {
                        self.animateSlideToMainScreen()
                    }
                }
            } else {
                loginVC.showAlert(message: "Incorrect email or password. Please try again.")
            }
        }
    }

    private func animateSlideToMainScreen() {
        let mainVC = TabbarFamilyViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)
        // Set initial position for the sliding animation
        navigationController.view.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        // Add main view controller to the window
        guard let window = UIApplication.shared.windows.first else { return }
        window.addSubview(navigationController.view)
        UIView.animate(withDuration: 0.5, animations: {
            // Slide out the current view and slide in the main view
            self.view.frame = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            navigationController.view.frame = window.bounds
        }) { _ in
            // Complete the transition and make main screen active
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    // Shake Animation Function
    private func animateShake(for view: UIView) {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 3
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 8, y: view.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 8, y: view.center.y))
        view.layer.add(shake, forKey: "position")
    }

    @objc func rememberMeTapped() {
        rememberMeButton.isSelected.toggle()
        print("Remember me tapped. Current state: \(rememberMeButton.isSelected ? "Selected" : "Deselected")")
    }

    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard
                .removeObject(
                    forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn
                )
            UserDefaultsStorageProfile.shared.clearProfile()
            guard let window = UIApplication.shared.windows.first else { return }
            let welcomeVC = WelcomeViewController()
            let navigationController = UINavigationController(rootViewController: welcomeVC)
            navigationController.view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
            UIView.animate(withDuration: 0.5, animations: {
                self.view.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height)
                navigationController.view.frame = window.bounds
            }) { _ in
                window.rootViewController = navigationController
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            showAlert(message: "Failed to log out. Please try again.")
        }
    }
}
