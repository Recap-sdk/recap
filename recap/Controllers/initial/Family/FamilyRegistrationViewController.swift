//
//  FamilyRegistrationViewController.swift
//  recap
//
//  Created by Diptayan Jash on 23/03/25.
//

import Foundation
import UIKit
import FirebaseStorage
import SwiftUICore
import FirebaseFirestore
import Lottie
import PhotosUI

class FamilyRegistrationViewController: UIViewController {
    var email: String = ""
    var userDocID: String = ""
    var profileImageURL: String = ""
    var selectedImage: UIImage?
    var currentStep = 0

    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.layer.shadowColor = Constants.FontandColors.defaultshadowColor
        view.layer.shadowOpacity = Float(Constants.FontandColors.defaultshadowOpacity)
        view.layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        view.layer.shadowRadius = Constants.FontandColors.defaultshadowRadius
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Join Family Circle"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Complete your profile to connect"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let stepsLabel: UILabel = {
        let label = UILabel()
        label.text = "STEP 1 OF 4"
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .systemBlue
        return label
    }()
    
    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Personal Information"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let fieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private static func createTextField(placeholder: String, iconName: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.keyboardType = keyboardType
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        
        // Create container view for icon
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        
        // Fix icon positioning and size to be consistent
        let iconView = UIImageView(frame: CGRect(x: 15, y: 13, width: 24, height: 24))
        iconView.image = UIImage(systemName: iconName)
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        containerView.addSubview(iconView)
        
        field.leftView = containerView
        field.leftViewMode = .always
        
        return field
    }

    // Now let's define our fields using the helper function
    let nameField: UITextField = {
        return createTextField(placeholder: "Full name", iconName: "person")
    }()

    let phoneField: UITextField = {
        return createTextField(placeholder: "Phone number", iconName: "phone", keyboardType: .numberPad)
    }()
    let relationField: UITextField = {
        let field = UITextField()
        field.placeholder = "Your Relationship"
        field.backgroundColor = .systemGray6
        field.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.translatesAutoresizingMaskIntoConstraints = false
        field.clearButtonMode = .whileEditing
        
        // Create container view for icon
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 50))
        
        // Fix icon positioning to match other fields
        let iconView = UIImageView(frame: CGRect(x: 15, y: 13, width: 24, height: 24))
        iconView.image = UIImage(systemName: "heart.fill")
        iconView.tintColor = .systemGray
        iconView.contentMode = .scaleAspectFit
        
        containerView.addSubview(iconView)
        
        field.leftView = containerView
        field.leftViewMode = .always
        
        return field
    }()
    
    private let profileImageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.isUserInteractionEnabled = true
        
        // Add camera icon overlay
        let cameraIconView = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraIconView.tintColor = .white
        cameraIconView.contentMode = .scaleAspectFit
        cameraIconView.tag = 100
        cameraIconView.frame = CGRect(x: 45, y: 45, width: 30, height: 30)
        imageView.addSubview(cameraIconView)
        
        // Add gradient overlay
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.4).cgColor]
        gradientLayer.locations = [0.6, 1.0]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        imageView.layer.addSublayer(gradientLayer)
        
        return imageView
    }()
    
    private let addPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "Add your photo"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .systemGray6
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.layer.sublayers?[1].cornerRadius = 4
        progress.layer.sublayers?[1].masksToBounds = true
        progress.progress = 0.25
        return progress
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        
        // Create shadow
        button.layer.shadowColor = UIColor.systemBlue.withAlphaComponent(0.5).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.5
        
        return button
    }()
    
    private let relations = ["Father", "Mother", "Sister", "Brother", "Spouse", "Other"]
    private var relationPicker = UIPickerView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupDelegates()
        setupRelationPickerView()
        updateUIForCurrentStep()
        
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        }
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Add views to hierarchy
        view.addSubview(cardView)
        view.addSubview(nextButton)
        
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)
        cardView.addSubview(stepsLabel)
        cardView.addSubview(stepTitleLabel)
        cardView.addSubview(progressView)
        cardView.addSubview(fieldContainer)
        
        fieldContainer.addSubview(nameField)
        fieldContainer.addSubview(phoneField)
        fieldContainer.addSubview(relationField)
        fieldContainer.addSubview(profileImageContainer)
        
        profileImageContainer.addSubview(profileImageView)
        profileImageContainer.addSubview(addPhotoLabel)
        
        // Configure auto layout
        cardView.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stepsLabel.translatesAutoresizingMaskIntoConstraints = false
        stepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        fieldContainer.translatesAutoresizingMaskIntoConstraints = false
        nameField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        relationField.translatesAutoresizingMaskIntoConstraints = false
        profileImageContainer.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        addPhotoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Card View
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cardView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30),
            
            // Title and Subtitle
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            // Steps information
            stepsLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            stepsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stepsLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            stepTitleLabel.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 8),
            stepTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stepTitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            
            // Progress
            progressView.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Field Container
            fieldContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 32),
            fieldContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            fieldContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            fieldContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            
            // Input Fields
            nameField.topAnchor.constraint(equalTo: fieldContainer.topAnchor),
            nameField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor),
            nameField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor),
            nameField.heightAnchor.constraint(equalToConstant: 60),
            
            phoneField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            phoneField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor),
            phoneField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor),
            phoneField.heightAnchor.constraint(equalToConstant: 60),
            
            relationField.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 16),
            relationField.leadingAnchor.constraint(equalTo: fieldContainer.leadingAnchor),
            relationField.trailingAnchor.constraint(equalTo: fieldContainer.trailingAnchor),
            relationField.heightAnchor.constraint(equalToConstant: 60),
            
            // Profile Image Container
            profileImageContainer.topAnchor.constraint(equalTo: fieldContainer.topAnchor, constant: 20),
            profileImageContainer.centerXAnchor.constraint(equalTo: fieldContainer.centerXAnchor),
            profileImageContainer.widthAnchor.constraint(equalToConstant: 200),
            profileImageContainer.heightAnchor.constraint(equalToConstant: 150),
            
            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: profileImageContainer.topAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // Add Photo Label
            addPhotoLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            addPhotoLabel.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            addPhotoLabel.leadingAnchor.constraint(equalTo: profileImageContainer.leadingAnchor),
            addPhotoLabel.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor),
            
            // Next Button
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nextButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        // Add action targets
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        // Add tap gesture to profile image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addPhotoTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        
        // Add tap gesture to relation field
        let relationTapGesture = UITapGestureRecognizer(target: self, action: #selector(showRelationPicker))
        relationField.addGestureRecognizer(relationTapGesture)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .systemBlue
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        cancelButton.tintColor = .secondaryLabel
        navigationItem.rightBarButtonItem = cancelButton
        
        // Hide the default back button
        navigationItem.hidesBackButton = true
    }
    
    private func setupDelegates() {
        nameField.delegate = self
        phoneField.delegate = self
        relationPicker.delegate = self
        relationPicker.dataSource = self
    }
    
    private func setupRelationPickerView() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneRelationPickerTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelRelationPickerTapped))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        relationField.inputView = relationPicker
        relationField.inputAccessoryView = toolBar
    }
    
    // MARK: - UI Update Methods
    private func updateUIForCurrentStep() {
        // Update step labels
        stepsLabel.text = "STEP \(currentStep + 1) OF 4"
        
        // Update progress
        progressView.progress = Float(currentStep + 1) / 4.0
        
        // Hide all fields
        nameField.isHidden = true
        phoneField.isHidden = true
        relationField.isHidden = true
        profileImageContainer.isHidden = true
        
        // Show fields based on current step
        switch currentStep {
        case 0:
            stepTitleLabel.text = "Personal Information"
            nameField.isHidden = false
            nextButton.setTitle("Continue", for: .normal)
        case 1:
            stepTitleLabel.text = "Contact Information"
            phoneField.isHidden = false
            nextButton.setTitle("Continue", for: .normal)
        case 2:
            stepTitleLabel.text = "Your Relationship"
            relationField.isHidden = false
            nextButton.setTitle("Continue", for: .normal)
        case 3:
            stepTitleLabel.text = "Profile Photo"
            profileImageContainer.isHidden = false
            nextButton.setTitle("Complete Registration", for: .normal)
        default:
            break
        }
        
        // Add animation
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        // Show confirmation alert
        let alert = UIAlertController(title: "Cancel Registration", message: "Are you sure you want to cancel? Your progress will be lost.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Continue Registration", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive, handler: { _ in
            self.dismiss(animated: true)
        }))
        
        present(alert, animated: true)
    }
    
    @objc private func nextTapped() {
        switch currentStep {
        case 0:
            guard let name = nameField.text, !name.isEmpty else {
                showErrorAnimation(for: nameField)
                return
            }
            animateToNextStep()
        case 1:
            guard let phone = phoneField.text, !phone.isEmpty else {
                showErrorAnimation(for: phoneField)
                return
            }
            animateToNextStep()
        case 2:
            guard let relation = relationField.text, !relation.isEmpty else {
                showErrorAnimation(for: relationField)
                return
            }
            animateToNextStep()
        case 3:
            guard selectedImage != nil else {
                showErrorAnimation(for: profileImageView)
                return
            }
            submitRegistration()
        default:
            break
        }
    }
    
    @objc private func backTapped() {
        if currentStep > 0 {
            currentStep -= 1
            updateUIForCurrentStep()
        }
    }
    
    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func showRelationPicker() {
        relationField.becomeFirstResponder()
    }
    
    @objc private func doneRelationPickerTapped() {
        let selectedRow = relationPicker.selectedRow(inComponent: 0)
        relationField.text = relations[selectedRow]
        view.endEditing(true)
    }
    
    @objc private func cancelRelationPickerTapped() {
        view.endEditing(true)
    }
    
    private func animateToNextStep() {
        // First animate out current fields
        UIView.animate(withDuration: 0.2, animations: {
            self.fieldContainer.alpha = 0
        }) { _ in
            // Update to next step
            self.currentStep += 1
            self.updateUIForCurrentStep()
            
            // Then animate in new fields
            self.fieldContainer.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.fieldContainer.alpha = 1
            }
        }
    }
    
    private func showErrorAnimation(for view: UIView) {
        // Vibrate
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        // Shake animation
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.6
        animation.values = [-10.0, 10.0, -8.0, 8.0, -5.0, 5.0, 0.0]
        view.layer.add(animation, forKey: "shake")
        
        // Highlight border in red
        let originalBorderColor = view.layer.borderColor
        let originalBorderWidth = view.layer.borderWidth
        
        UIView.animate(withDuration: 0.1, animations: {
            view.layer.borderColor = UIColor.systemRed.cgColor
            view.layer.borderWidth = 2.0
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                view.layer.borderColor = originalBorderColor
                view.layer.borderWidth = originalBorderWidth
            }
        }
    }
    
    private func submitRegistration() {
        let loadingAnimation = showLoadingAnimation()
        guard let name = nameField.text, !name.isEmpty,
              let phone = phoneField.text, !phone.isEmpty,
              let relation = relationField.text, !relation.isEmpty,
              let image = selectedImage else {
            showAlert(message: "Please fill in all fields")
            return
        }
        
        // Upload image to Firebase Storage
        uploadImage(image) { [weak self] imageURL in
            guard let self = self else { return }
            
            let db = Firestore.firestore()
            let firestoreData: [String: Any] = [
                "name": name,
                "email": self.email,
                "phone": phone,
                "relation": relation,
                "imageURL": imageURL,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            // Create data for UserDefaults without timestamp
            let userDefaultsData: [String: Any] = [
                "name": name,
                "email": self.email,
                "phone": phone,
                "relation": relation,
                "imageURL": imageURL
            ]
            
            db.collection("users").document(self.userDocID).collection("family_members").addDocument(data: firestoreData) { [weak self] error in
                guard let self = self else { return }
                
                removeLoadingAnimation(loadingAnimation)
                
                if let error = error {
                    self.showAlert(message: "Error registering family member: \(error.localizedDescription)")
                    return
                }
                
                // Save family member details to UserDefaults
                UserDefaults.standard.set(userDefaultsData, forKey: "familyMemberDetails")
                UserDefaults.standard.set(imageURL, forKey: Constants.UserDefaultsKeys.familyMemberImageURL)
                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn)
                UserDefaults.standard.synchronize()
                
                self.fetchPatientDetails(userDocID: self.userDocID)

            }
        }
    }
    
    private func uploadImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion("")
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageName = "\(UUID().uuidString).jpg"
        let imageRef = storageRef.child("family_members/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Show upload progress indicator
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        loadingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView.tag = 999
        
        let progressIndicator = UIProgressView(progressViewStyle: .bar)
        progressIndicator.progressTintColor = .systemBlue
        progressIndicator.trackTintColor = .white
        progressIndicator.progress = 0.0
        progressIndicator.frame = CGRect(x: 50, y: view.center.y, width: view.frame.width - 100, height: 10)
        progressIndicator.layer.cornerRadius = 5
        progressIndicator.clipsToBounds = true
        
        loadingView.addSubview(progressIndicator)
        view.addSubview(loadingView)
        
        // Upload with progress tracking
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { metadata, error in
            // Remove loading view
            loadingView.removeFromSuperview()
            
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion("")
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    completion("")
                    return
                }
                
                completion(url?.absoluteString ?? "")
            }
        }
    }
    private func fetchPatientDetails(userDocID: String) {
        let loadingAnimation = showLoadingAnimation()
        let db = Firestore.firestore()
        db.collection("users").document(userDocID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            removeLoadingAnimation(loadingAnimation)
            
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
}
// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension FamilyRegistrationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relations.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relations[row]
    }
}

// MARK: - UITextFieldDelegate
extension FamilyRegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - PHPickerViewControllerDelegate
extension FamilyRegistrationViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider else { return }

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                guard let self = self,
                      let image = image as? UIImage else { return }

                DispatchQueue.main.async {
                    self.selectedImage = image
                    self.profileImageView.image = image
                }
            }
        }
    }
}

#Preview { FamilyRegistrationViewController() }
