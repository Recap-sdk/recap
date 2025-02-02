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
        
        guard let verifyUID = self as? FamilyLoginViewController else { return }

        let patientUID = verifyUID.patientUIDField.text ?? ""
        print("Patient UID entered: \(patientUID)")  // Log the entered patient UID
        
        let db = Firestore.firestore()

        db.collection("users").getDocuments { (usersSnapshot, error) in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                verifyUID.showAlert(message: "Unable to retrieve user details.")
                return
            }

            guard let userDocs = usersSnapshot?.documents, !userDocs.isEmpty else {
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
                    
                    // Change the verifyButton's appearance to indicate success
                    verifyUID.verifyButton.setTitle("Verified", for: .normal)
                    verifyUID.verifyButton.backgroundColor = .systemGreen
                    
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
        
        // Retrieve the document ID from UserDefaults
        guard let userDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") else {
            print("No user document found. Please verify UID first.")
            loginVC.showAlert(message: "Please verify patient UID first.")
            return
        }

        let patientEmail = loginVC.emailField.text ?? ""
        let enteredPassword = loginVC.passwordField.text ?? ""
        
        print("Email entered: \(patientEmail)")  // Log the entered email
        print("Password entered: \(enteredPassword)")  // Log the entered password

        let db = Firestore.firestore()

        db.collection("users").document(userDocID).collection("family_members").getDocuments { (familySnapshot, error) in
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

            for familyDoc in familyDocs {
                let familyData = familyDoc.data()
                // Log the fetched family member data for debugging purposes
                print("Fetched family member data: \(familyData)")
                
                if let storedPassword = familyData["password"] as? String, storedPassword == enteredPassword,
                   let email = familyData["email"] as? String, email == patientEmail {
                    matchedFamilyMember = familyData
                    break
                }
            }

            if let _ = matchedFamilyMember {
                print("Family member authenticated")
                let reportsVC = FamilyViewController()
                if let navController = self.navigationController {
                    navController.pushViewController(reportsVC, animated: true)
                } else {
                    self.present(reportsVC, animated: true)
                }
            } else {
                self.showAlert(message: "Incorrect email or password. Please try again.")
            }
        }
    }
    
    
    @objc func rememberMeTapped() {
        rememberMeButton.isSelected.toggle()
        print("Remember me tapped. Current state: \(rememberMeButton.isSelected ? "Selected" : "Deselected")")
    }

    
    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            UserDefaults.standard.removeObject(forKey: "hasCompletedProfile")
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
