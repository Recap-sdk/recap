//
//  launchScreenViewController.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class launchScreenViewController: UIViewController {
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "recapLogo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
//            UIColor.systemBlue.cgColor,
//            UIColor.systemPurple.cgColor
            UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
            UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor,
        ]
//        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateLogo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Setup

    private func setupUI() {
        view.layer.insertSublayer(gradientLayer, at: 0)

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        logoImageView.alpha = 0
    }

    private func animateLogo() {
        // Fade in animation
        UIView.animate(withDuration: 1.0, animations: { [weak self] in
            self?.logoImageView.alpha = 1
        }) { [weak self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.transitionToMainScreen()
            }
        }
    }

    func transitionToMainScreen() {
        // If onboarding is not completed, present it
        if !UserDefaults.standard
            .bool(forKey: Constants.UserDefaultsKeys.HasCompletedOnboarding) {
            let onboardingVC = OnboardingViewController()
            let navController = UINavigationController(rootViewController: onboardingVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.custom(
                    identifier: .init(
                        "customHeight"
                    ),
                    resolver: { _ in
                        return UIScreen.main.bounds.height * 0.83
                    })]
                sheet.prefersGrabberVisible = true
                sheet.prefersEdgeAttachedInCompactHeight = true
            }
            present(navController, animated: true)
        } else {
            // If onboarding is completed, handle user login state
            if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn) {
                // Navigate to the family tab bar if family member is logged in
                let familyTabBarVC = TabbarFamilyViewController()
                transitionToRootViewController(familyTabBarVC)
            } else if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasPatientCompletedProfile) {
                // Check if the user is actually logged in with Firebase
                if let userId = Auth.auth().currentUser?.uid {
                    // Verify profile completeness in Firebase
                    checkProfileCompleteness(userId: userId)
                } else {
                    // No Firebase user, go to welcome screen
                    navigateToWelcomeScreen()
                }
            } else {
                // Navigate to the welcome screen if neither condition is met
                navigateToWelcomeScreen()
            }
        }
    }
    
    private func checkProfileCompleteness(userId: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                self.navigateToWelcomeScreen()
                return
            }
            
            if let document = document, document.exists, let userData = document.data() {
                // Check if profile is complete by verifying required fields
                let requiredFields = ["firstName", "lastName", "dateOfBirth", "sex", "bloodGroup", "stage"]
                let isProfileComplete = requiredFields.allSatisfy { field in
                    guard let value = userData[field] as? String else { return false }
                    return !value.isEmpty
                }
                
                if isProfileComplete {
                    // Profile is complete, navigate to main view
                    let patientTabBarVC = TabbarViewController()
                    self.transitionToRootViewController(patientTabBarVC)
                } else {
                    // Profile exists but is incomplete, navigate to profile completion
                    let patientInfoVC = patientInfo()
                    // Set the delegate to SceneDelegate to handle navigation after profile completion
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        patientInfoVC.delegate = sceneDelegate
                    }
                    let nav = UINavigationController(rootViewController: patientInfoVC)
                    nav.modalPresentationStyle = .fullScreen
                    self.transitionToRootViewController(nav)
                }
            } else {
                // No user document, go to welcome screen
                self.navigateToWelcomeScreen()
            }
        }
    }
    
    private func navigateToWelcomeScreen() {
        let welcomeVC = WelcomeViewController()
        let navController = UINavigationController(rootViewController: welcomeVC)
        navController.modalPresentationStyle = .fullScreen
        transitionToRootViewController(navController)
    }

    private func transitionToRootViewController(_ viewController: UIViewController) {
        guard let window = view.window else { return }
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        })
    }
}

#Preview {
    launchScreenViewController()
}
