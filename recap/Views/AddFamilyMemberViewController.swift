import FirebaseAuth
import PhotosUI
import UIKit

class AddFamilyMemberViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private var selectedImage: UIImage?
    private var storage: FamilyStorageProtocol
    private let dataUploadManager: DataUploadManager
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    struct ValidationError: Error {
        let message: String
    }

    init(
        storage: FamilyStorageProtocol = UserDefaultsStorageFamilyMember.shared,
        dataUploadManager: DataUploadManager = DataUploadManager()
    ) {
        self.storage = storage
        self.dataUploadManager = dataUploadManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        storage = UserDefaultsStorageFamilyMember.shared
        dataUploadManager = DataUploadManager()
        super.init(coder: coder)
    }

    private let relationshipOptions = RelationshipCategory.allCases
    private let relationshipPicker = UIPickerView()
    private let pickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        return toolbar
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        return view
    }()

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .systemGray3
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    private let addPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17)
        return textField
    }()

    private let relationshipTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Relationship (e.g., Son, Daughter)"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17)
        return textField
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17)
        textField.keyboardType = .phonePad
        return textField
    }()

    private func validatePhone(_ phone: String) -> Bool {
        // Remove any non-numeric characters from the phone number
        let digitsOnly = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        // Check if the resulting string is exactly 10 digits
        return digitsOnly.count == 10
    }

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email Address"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17)
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        return textField
    }()

    private func validateEmail(_ email: String) -> Bool {
        // Email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 17)
        textField.isSecureTextEntry = true
        return textField
    }()

    private func validatePassword(_ password: String) -> (isValid: Bool, message: String) {
        // Password validation rules
        let minLength = 4
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        let hasSpecialCharacter = password.range(of: "[!@#$%^&*(),.?\":{}|<>]", options: .regularExpression) != nil

        if password.count < minLength {
            return (false, "Password must be at least \(minLength) characters long")
        }
        if !hasUppercase {
            return (false, "Password must contain at least one uppercase letter")
        }
        if !hasLowercase {
            return (false, "Password must contain at least one lowercase letter")
        }
        if !hasSpecialCharacter {
            return (false, "Password must contain at least one special character")
        }

        return (true, "")
    }

    private func validateInputs() throws {
        guard let name = nameTextField.text, !name.isEmpty else {
            throw ValidationError(message: "Please enter a name")
        }

        guard let relationship = relationshipTextField.text, !relationship.isEmpty else {
            throw ValidationError(message: "Please select a relationship")
        }

        guard let phone = phoneTextField.text, !phone.isEmpty else {
            throw ValidationError(message: "Please enter a phone number")
        }

        if !validatePhone(phone) {
            throw ValidationError(message: "Phone number must be exactly 10 digits")
        }

        guard let email = emailTextField.text, !email.isEmpty else {
            throw ValidationError(message: "Please enter an email address")
        }

        if !validateEmail(email) {
            throw ValidationError(message: "Please enter a valid email address")
        }

        guard let password = passwordTextField.text, !password.isEmpty else {
            throw ValidationError(message: "Please enter a password")
        }

        let passwordValidation = validatePassword(password)
        if !passwordValidation.isValid {
            throw ValidationError(message: passwordValidation.message)
        }

        guard profileImageView.image != nil else {
            throw ValidationError(message: "Please select a profile image")
        }
    }

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Family Member", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
        setupRelationshipPicker()

        let doneButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(closeButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        if let sheet = sheetPresentationController {
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }

        let Dismisskeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Dismisskeyboard)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Add Family Member"

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [scrollView, contentView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [profileImageView, addPhotoButton, nameTextField, relationshipTextField,
         phoneTextField, emailTextField, passwordTextField, addButton].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        profileImageView.layer.cornerRadius = 50

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor), // Correctly set the bottom constraint
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            addPhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            addPhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nameTextField.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),

            relationshipTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 16),
            relationshipTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            relationshipTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            relationshipTextField.heightAnchor.constraint(equalToConstant: 44),

            phoneTextField.topAnchor.constraint(equalTo: relationshipTextField.bottomAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            phoneTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),

            emailTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 16),
            emailTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordTextField.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),

            // Fix the bottom spacing between the addButton and contentView bottom
            addButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 32),
            addButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            addButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)

        addPhotoButton.addTarget(self, action: #selector(profileImageTapped), for: .touchUpInside)
    }

    private func setupRelationshipPicker() {
        relationshipPicker.delegate = self
        relationshipPicker.dataSource = self
        relationshipTextField.inputView = relationshipPicker
        relationshipTextField.inputAccessoryView = pickerToolbar

        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePickingRelationship))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolbar.setItems([flexibleSpace, doneButton], animated: false)
    }

    @objc private func donePickingRelationship() {
        let selectedRow = relationshipPicker.selectedRow(inComponent: 0)
        let selectedRelationship = relationshipOptions[selectedRow]
        relationshipTextField.text = selectedRelationship.rawValue
        relationshipTextField.resignFirstResponder()
    }

    @objc private func profileImageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        //        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func addButtonTapped() {
        do {
            try validateInputs()
            
            // Proceed with adding family member if validation is successful
            guard let name = nameTextField.text,
                  let relationship = relationshipTextField.text,
                  let phone = phoneTextField.text,
                  let email = emailTextField.text,
                  let password = passwordTextField.text,
                  let image = profileImageView.image,
                  let patientId = Auth.auth().currentUser?.uid else {
                return
            }
            
            // Clean phone number
            let cleanPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            
            let newMemberId = UUID().uuidString
            let imagePath = "\(patientId)/FAMILY_IMGS/\(newMemberId).jpg"
            
            disableUIForUpload()
            
            FirebaseManager.shared.uploadFamilyMemberImage(patientId: patientId, imagePath: imagePath, image: image) { [weak self] imageURL, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.enableUIAfterUpload()
                    self.showAlert(title: "Upload Error", message: "Failed to upload image: \(error.localizedDescription)", retry: true)
                    return
                }
                
                guard let imageURL = imageURL else {
                    self.enableUIAfterUpload()
                    self.showAlert(title: "Error", message: "Could not retrieve image URL.", retry: true)
                    return
                }
                
                let newMember = FamilyMember(
                    id: newMemberId,
                    name: name,
                    relationship: relationship,
                    phone: cleanPhone,
                    email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                    password: password,
                    imageName: newMemberId,
                    imageURL: imageURL
                )
                
                self.dataUploadManager.addFamilyMember(for: patientId, member: newMember) { error in
                    DispatchQueue.main.async {
                        self.enableUIAfterUpload()
                        if let error = error {
                            self.showAlert(title: "Error", message: "Failed to save family member: \(error.localizedDescription)", retry: true)
                        } else {
                            self.showSuccessAnimation {
                                self.showAlert(title: "Success", message: "Family member added successfully") {
                                    self.dismiss(animated: true)
                                }
                            }
                        }
                    }
                }
            }
        } catch let validationError as ValidationError {
            showAlert(title: "Validation Error", message: validationError.message, retry: true)
        } catch {
            showAlert(title: "Error", message: "An unexpected error occurred", retry: true)
        }
    }

    private func disableUIForUpload() {
        addButton.isEnabled = false
        addButton.setTitle("Adding \(nameTextField.text ?? "family")", for: .normal)
        activityIndicator.startAnimating()
    }

    // Re-enable UI elements after upload
    private func enableUIAfterUpload() {
        addButton.isEnabled = true
        addButton.setTitle("Add Family Member", for: .normal)
        activityIndicator.stopAnimating()
    }

    // Success animation (simple scale animation)
    private func showSuccessAnimation(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            self.profileImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.profileImageView.transform = .identity
            }, completion: { _ in
                completion()
            })
        })
    }
    private func showAlert(title: String, message: String, retry: Bool = false) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: retry ? "Retry" : "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddFamilyMemberViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            if let image = image as? UIImage {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)

        if let editedImage = info[.editedImage] as? UIImage {
            profileImageView.image = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            profileImageView.image = originalImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension AddFamilyMemberViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationshipOptions.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationshipOptions[row].rawValue
    }
}
