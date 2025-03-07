//
//  launchScreenViewController.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import UIKit

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
            } else if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.hasPatientCompletedProfile) ||
                      UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isPatientLoggedIn) {
                // Navigate to the patient tab bar if patient profile is completed or patient is logged in
                let patientTabBarVC = TabbarViewController()
                transitionToRootViewController(patientTabBarVC)
            } else {
                // Navigate to the welcome screen if neither condition is met
                let welcomeVC = WelcomeViewController()
                let navController = UINavigationController(rootViewController: welcomeVC)
                navController.modalPresentationStyle = .fullScreen
                transitionToRootViewController(navController)
            }
        }
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
