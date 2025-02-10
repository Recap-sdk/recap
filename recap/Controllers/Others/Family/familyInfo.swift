//
//  familyInfo.swift
//  recap
//
//  Created by user@47 on 29/01/25.
//

import FirebaseAuth
import UIKit

// MARK: - FamilyMemberDetails
struct FamilyMemberDetails {
    let firstName: String
    let lastName: String
    let dateOfBirth: String
    let relationship: String
    let bloodGroup: String
    let id: String

    var dictionary: [String: Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "dateOfBirth": dateOfBirth,
            "relationship": relationship,
            "bloodGroup": bloodGroup,
            "id": id
        ]
    }
}

// MARK: - RelationshipOptions
enum RelationshipOptions: String, CaseIterable {
    case parent = "Parent"
    case sibling = "Sibling"
    case spouse = "Spouse"
    case child = "Child"
    case other = "Other"
}

// MARK: - FamilyInfoDelegate
protocol FamilyInfoDelegate: AnyObject {
    func didSaveFamilyMember(_ member: FamilyMemberDetails)
}

// MARK: - familyInfo class
class familyInfo: UIViewController {
    weak var delegate: FamilyInfoDelegate?

    private var storage: ProfileStorageProtocol

    init(storage: ProfileStorageProtocol = UserDefaultsStorageProfile.shared) {
        self.storage = storage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        storage = UserDefaultsStorageProfile.shared
        super.init(coder: coder)
    }

    // MARK: - UI Components
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()

    private let firstNameField = CustomTextField(placeholder: "First Name")
    private let lastNameField = CustomTextField(placeholder: "Last Name")
    private let dobField = CustomTextField(placeholder: "Date of Birth")
    private let relationshipField = CustomTextField(placeholder: "Relationship")
    private let bloodGroupField = CustomTextField(placeholder: "Blood Group")

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }()

    // MARK: - Properties
    private let imagePicker = UIImagePickerController()
    private let datePicker = UIDatePicker()
    private let relationshipPicker = UIPickerView()
    private let bloodGroupPicker = UIPickerView()

    let relationshipOptions = RelationshipOptions.allCases.map { $0.rawValue }
    let bloodGroupOptions = BloodGroupOptions.allCases.map { $0.rawValue }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        title = "Add Family Member"
        super.viewDidLoad()
        setupUI()
//        setupImagePicker()
//        setupPickers()
//        setupTextFields()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        [profileImageView, stackView, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [firstNameField, lastNameField, dobField, relationshipField, bloodGroupField].forEach {
            stackView.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            stackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
        ])

//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
//        profileImageView.addGestureRecognizer(tapGesture)

        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func saveButtonTapped() {
        // Validate inputs
        guard let firstName = firstNameField.text, !firstName.isEmpty,
              let lastName = lastNameField.text, !lastName.isEmpty,
              let dob = dobField.text, !dob.isEmpty,
              let relationship = relationshipField.text, !relationship.isEmpty,
              let bloodGroup = bloodGroupField.text, !bloodGroup.isEmpty else {
            showAlert(message: "Please fill in all fields")
            return
        }

        // Create family member details object
        guard let userId = Auth.auth().currentUser?.uid else {
            showAlert(message: "User not logged in.")
            return
        }

        let familyMemberDetails = FamilyMemberDetails(firstName: firstName,
                                                     lastName: lastName,
                                                     dateOfBirth: dob,
                                                     relationship: relationship,
                                                     bloodGroup: bloodGroup,
                                                     id: userId)

        // Save to UserDefaults
        UserDefaultsStorageProfile.shared.saveProfile(
            details: familyMemberDetails.dictionary,
            image: profileImageView.image
        ) { [weak self] success in
            if success {
                // Notify delegate and pop the view
                self?.delegate?.didSaveFamilyMember(familyMemberDetails)
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.showAlert(message: "Failed to save family member to UserDefaults")
            }
        }
    }

    // MARK: - Helper Methods
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
