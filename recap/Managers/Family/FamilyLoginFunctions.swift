//
//  FamilyLoginFunctions.swift
//  recap
//
//  Created by s1834 on 29/01/25.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import UIKit
import Lottie

extension FamilyLoginViewController {
    @objc func verifyPatientUID() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.color = .white
        verifyButton.setTitle("", for: .normal)
        verifyButton.addSubview(spinner)
        spinner.center = CGPoint(x: verifyButton.bounds.midX, y: verifyButton.bounds.midY)

        let patientUID = patientUIDField.text ?? ""
        let db = Firestore.firestore()

        db.collection("users").getDocuments { usersSnapshot, error in
            spinner.stopAnimating()
            self.verifyButton.setTitle("Verify", for: .normal)
            guard error == nil else {
                self.showAlert(message: "Unable to retrieve user details.")
                return
            }

            guard let userDocs = usersSnapshot?.documents, !userDocs.isEmpty else {
                self.animateShake(for: self.patientUIDField)
                self.showAlert(message: "No users found.")
                return
            }

            for userDoc in userDocs {
                if let storedUID = userDoc.data()["patientUID"] as? String, storedUID == patientUID {
                    UserDefaults.standard.set(userDoc.documentID, forKey: "verifiedUserDocID")
                    self.googleSignInButton.isEnabled = true
                    self.appleSignInButton.isEnabled = true

                    UIView.animate(withDuration: 0.3) {
                        self.verifyButton.setTitle("Verified", for: .normal)
                        self.verifyButton.backgroundColor = AppColors.iconColor
                        self.verifyButton.setTitleColor(.white, for: .normal)
                    }
                    return
                }
            }

            self.showAlert(message: "Patient UID does not match. Please try again.")
        }
    }

    @objc func googleSignInTapped() {
        guard let userDocID = UserDefaults.standard.string(forKey: "verifiedUserDocID") else {
            showAlert(message: "Please verify patient UID first.")
            return
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(message: "Google Sign-In not configured.")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let loadingAnimation = self.showLoadingAnimation()
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.stopLoadingAnimation(loadingAnimation)
                self.showAlert(message: "Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user else {
                self.stopLoadingAnimation(loadingAnimation)
                self.showAlert(message: "Failed to get user information")
                return
            }

            // Get user's email and profile picture
            let email = user.profile?.email ?? ""
            let profileImageURL = user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""

            // Check if this email is already registered as a family member
            let db = Firestore.firestore()
            db.collection("users").document(userDocID).collection("family_members")
                .whereField("email", isEqualTo: email)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.stopLoadingAnimation(loadingAnimation)
                        self.showAlert(message: "Error checking family member status: \(error.localizedDescription)")
                        return
                    }

                    if let documents = snapshot?.documents, !documents.isEmpty {
                        // Family member exists, proceed with login
                        let familyData = documents[0].data()
                        
                        // Create UserDefaults data without any Firestore-specific fields
                        let userDefaultsData: [String: Any] = [
                            "name": familyData["name"] as? String ?? "",
                            "email": familyData["email"] as? String ?? "",
                            "phone": familyData["phone"] as? String ?? "",
                            "relation": familyData["relation"] as? String ?? "",
                            "imageURL": profileImageURL
                        ]
                        
                        UserDefaults.standard.set(userDefaultsData, forKey: "familyMemberDetails")
                        UserDefaults.standard.set(profileImageURL, forKey: Constants.UserDefaultsKeys.familyMemberImageURL)
                        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn)
                        UserDefaults.standard.synchronize()

                        // Fetch patient details
                        self.fetchPatientDetails(userDocID: userDocID, loadingAnimation: loadingAnimation)
                    } else {
                        // New family member, show registration screen
                        self.stopLoadingAnimation(loadingAnimation)
                        self.showFamilyRegistration(email: email, profileImageURL: profileImageURL, userDocID: userDocID)
                    }
                }
        }
    }
    
    @objc func appleSignInTapped() {
        print("Apple Sign-In tapped")
    }

    private func showFamilyRegistration(email: String, profileImageURL: String, userDocID: String) {
        let registrationVC = FamilyRegistrationViewController()
        registrationVC.email = email
        registrationVC.profileImageURL = profileImageURL
        registrationVC.userDocID = userDocID
        let navController = UINavigationController(rootViewController: registrationVC)
        present(navController, animated: true)
    }

    private func fetchPatientDetails(userDocID: String, loadingAnimation: LottieAnimationView) {
        let db = Firestore.firestore()
        db.collection("users").document(userDocID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            self.stopLoadingAnimation(loadingAnimation)

            if let error = error {
                print("Error fetching patient details: \(error.localizedDescription)")
                return
            }

            guard let document = document, document.exists else {
                print("Patient document not found.")
                return
            }

            let userData = document.data() ?? [:]
            UserDefaults.standard.set(userData, forKey: "patientDetails")

            DispatchQueue.main.async {
                self.animateSlideToMainScreen()
            }
        }
    }

    private func animateSlideToMainScreen() {
        let mainVC = TabbarFamilyViewController()
        let navigationController = UINavigationController(rootViewController: mainVC)

        guard let window = UIApplication.shared.windows.first else { return }
        window.addSubview(navigationController.view)
        navigationController.view.frame = CGRect(x: window.frame.width, y: 0, width: window.frame.width, height: window.frame.height)

        UIView.animate(withDuration: 0.5, animations: {
            self.view.frame.origin.x = -self.view.frame.width
            navigationController.view.frame = window.bounds
        }) { _ in
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    private func animateShake(for view: UIView) {
        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.05
        shake.repeatCount = 3
        shake.autoreverses = true
        shake.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 8, y: view.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 8, y: view.center.y))
        view.layer.add(shake, forKey: "position")
    }
//    private func showLoadingAnimation() -> LottieAnimationView {
//        let animationView = LottieAnimationView(name: "loading")
//        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//        animationView.center = view.center
//        animationView.loopMode = .loop
//        animationView.animationSpeed = 1.5
//        view.addSubview(animationView)
//        animationView.play()
//        return animationView
//    }

    private func stopLoadingAnimation(_ animationView: LottieAnimationView) {
        DispatchQueue.main.async {
            animationView.stop()
            animationView.removeFromSuperview()
        }
    }
    
    @objc func logoutTapped() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()

            UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn)
            UserDefaultsStorageProfile.shared.clearProfile()

            guard let window = UIApplication.shared.windows.first else { return }
            let welcomeVC = WelcomeViewController()
            let navigationController = UINavigationController(rootViewController: welcomeVC)

            window.rootViewController = navigationController
            window.makeKeyAndVisible()

            UIView.animate(withDuration: 0.5) {
                self.view.frame.origin.y = window.frame.height
                navigationController.view.frame = window.bounds
            }
        } catch {
            showAlert(message: "Failed to log out. Please try again.")
        }
    }
}
