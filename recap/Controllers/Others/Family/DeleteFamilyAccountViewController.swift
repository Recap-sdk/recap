//
//  DeleteFamilyAccountViewController.swift
//  recap
//
//  Created on 31/05/25.
//

import Lottie
import UIKit

class DeleteFamilyAccountViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Delete Family Account"
        label.font = Constants.FontandColors.titleFont
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text =
            "Deleting your family member account will permanently remove your access to the patient's information. Your profile data will be deleted. This action cannot be undone."
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let warningIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemRed
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = .systemGray5
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "Delete Account"

        view.addSubview(warningIconView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(deleteButton)
        view.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            warningIconView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            warningIconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningIconView.widthAnchor.constraint(equalToConstant: 80),
            warningIconView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: warningIconView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            cancelButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),

            deleteButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20),
            deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            deleteButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func deleteButtonTapped() {
        let alertController = UIAlertController(
            title: "Confirm Account Deletion",
            message:
                "This action will permanently delete your family member account and remove your access to the patient. This cannot be undone. Are you sure you want to proceed?",
            preferredStyle: .alert
        )

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alertController.addAction(
            UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.initiateAccountDeletion()
            })

        present(alertController, animated: true)
    }

    private func initiateAccountDeletion() {
        let loadingAnimation = showLoadingAnimation()

        AccountDeletionManager.shared.deleteFamilyMemberAccount { [weak self] success, error in
            guard let self = self else { return }

            loadingAnimation.stop()
            loadingAnimation.removeFromSuperview()

            if success {
                self.showDeletionSuccessAlert()
            } else {
                let errorMessage = error?.localizedDescription ?? "An unknown error occurred"
                self.showAlert(message: "Account deletion failed: \(errorMessage)")
            }
        }
    }

    private func showDeletionSuccessAlert() {
        let alertController = UIAlertController(
            title: "Account Deleted",
            message:
                "Your family member account has been successfully deleted. Thank you for using our app.",
            preferredStyle: .alert
        )

        alertController.addAction(
            UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigateToWelcomeScreen()
            })

        present(alertController, animated: true)
    }

    private func navigateToWelcomeScreen() {
        guard let window = UIApplication.shared.windows.first else { return }

        let welcomeVC = WelcomeViewController()
        let navigationController = UINavigationController(rootViewController: welcomeVC)

        window.rootViewController = navigationController
        window.makeKeyAndVisible()

        UIView.transition(
            with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
    }

    private func showLoadingAnimation() -> LottieAnimationView {
        let animationView = LottieAnimationView(name: "loading")
        animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        animationView.center = view.center
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        view.addSubview(animationView)
        animationView.play()
        return animationView
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
}
