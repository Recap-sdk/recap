//
//  AddQuestionViewController.swift
//
//  Created by admin70 on 13/11/24.
//

import FirebaseFirestore
import FirebaseStorage
import UIKit

class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var selectedImageURL: String?
    private var selectedAudioURL: String?

    // MARK: - UI Elements

    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Category", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let timeFrameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Time Frame", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let questionTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "What did you eat?"
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 10
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 26)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.systemGray5
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()

    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .red // Red cross
        button.backgroundColor = .white // White background
        button.layer.cornerRadius = 12 // Round button

        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button

    }()

    private var optionTextFields: [UITextField] = {
        var textFields = [UITextField]()
        for i in 1 ... 4 {
            let textField = UITextField()
            textField.placeholder = "Option \(i)"
            textField.backgroundColor = UIColor.systemGray6
            textField.layer.cornerRadius = 10
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textFields.append(textField)
        }
        return textFields
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Properties

    private let categories = ["Immediate", "Recent", "Remote"]
    private var selectedCategory: String? {
        didSet {
            categoryButton.setTitle(selectedCategory ?? "Select Category", for: .normal)
        }
    }

    private let timeFrame = ["Morning", "Afternoon", "Evening", "Night"]
    private var selectedTimeFrame: String? {
        didSet {
            timeFrameButton.setTitle(selectedTimeFrame ?? "Select Time Frame", for: .normal)
        }
    }

    var verifiedUserDocID: String

    // Initialize with the already fetched verifiedUserDocID
    required init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add Question"

        categoryButton.addTarget(self, action: #selector(showCategoryPicker), for: .touchUpInside)
        timeFrameButton.addTarget(self, action: #selector(showTimeFramePicker), for: .touchUpInside)
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
        cancelImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)

        setupLayout()

        let Dismisskeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(Dismisskeyboard)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        view.addSubview(questionTextField)
        view.addSubview(addImageButton)
        view.addSubview(imageView)
        optionTextFields.forEach { view.addSubview($0) }
        view.addSubview(saveButton)
        view.addSubview(cancelImageButton)

        NSLayoutConstraint.activate([
            cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -10),
            cancelImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            cancelImageButton.widthAnchor.constraint(equalToConstant: 24),
            cancelImageButton.heightAnchor.constraint(equalToConstant: 24),
        ])

        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: addImageButton.leadingAnchor, constant: -10),
            questionTextField.heightAnchor.constraint(equalToConstant: 50),

            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addImageButton.centerYAnchor.constraint(equalTo: questionTextField.centerYAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 40),
            addImageButton.heightAnchor.constraint(equalToConstant: 40),

            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 10),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        for (index, optionTextField) in optionTextFields.enumerated() {
            NSLayoutConstraint.activate([
                optionTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: CGFloat(10 + index * 55)),
                optionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                optionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                optionTextField.heightAnchor.constraint(equalToConstant: 50),
            ])
        }

        if let lastOption = optionTextFields.last {
            let buttonStack = UIStackView(arrangedSubviews: [categoryButton, timeFrameButton])
            buttonStack.axis = .horizontal
            buttonStack.spacing = 20
            buttonStack.alignment = .fill
            buttonStack.distribution = .fillEqually
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttonStack)

            NSLayoutConstraint.activate([
                buttonStack.topAnchor.constraint(equalTo: lastOption.bottomAnchor, constant: 30),
                buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonStack.heightAnchor.constraint(equalToConstant: 50),
            ])

            NSLayoutConstraint.activate([
                saveButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
                saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                saveButton.widthAnchor.constraint(equalToConstant: 250),
                saveButton.heightAnchor.constraint(equalToConstant: 50),
            ])
        }
    }

    // MARK: - Category Picker

    @objc private func showCategoryPicker() {
        let pickerVC = CategoryPickerViewController(categories: categories) { selectedCategory in
            self.selectedCategory = selectedCategory
        }
        present(pickerVC, animated: true)
    }

    @objc private func showTimeFramePicker() {
        let pickerVC = CategoryPickerViewController(categories: timeFrame) { selectedTimeFrame in
            self.selectedTimeFrame = selectedTimeFrame
        }
        present(pickerVC, animated: true)
    }

    // MARK: - Firestore Logic

    @objc private func saveQuestion() {
        guard let category = selectedCategory else {
            showAlert(title: "⚠️ Missing Category", message: "Please select a category before saving.📌")
            return
        }

        guard let selectedTimeFrame = selectedTimeFrame else {
            showAlert(title: "⏰ Missing Time Frame", message: "Please select a time frame before saving.")
            return
        }

        let questionText = questionTextField.text ?? ""
        let optionTexts = optionTextFields.map { $0.text ?? "" }
        let filledOptions = optionTexts.filter { !$0.isEmpty }

        guard !questionText.isEmpty, !optionTexts.contains(where: { $0.isEmpty }) else {
            showAlert(title: "📝 Incomplete Fields", message: "Please fill in all fields before saving.")
            return
        }

        guard filledOptions.count >= 2 else {
            showAlert(title: "⚠️ Incomplete Options", message: "Please provide at least 2 options. ✅✅")
            return
        }

        // Determine askInterval based on category, default is 6 hours (21600 sec)
        let askInterval: Int
        switch category {
        case "Immediate": askInterval = 14400 // 4 hours
        case "Recent": askInterval = 86400 // 1 day
        case "Remote": askInterval = 31536000 // 1 year (configurable)
        default: askInterval = 21600 // Default: 6 hours
        }

        // Determine timeFrame range
        let timeFrame: (from: String, to: String)
        switch selectedTimeFrame {
        case "Morning": timeFrame = ("06:00", "11:59")
        case "Afternoon": timeFrame = ("12:00", "17:59")
        case "Evening": timeFrame = ("18:00", "23:59")
        case "Night": timeFrame = ("00:00", "05:59")
        default:
            showAlert(title: "⏰ Invalid Time Frame", message: "Please select a valid time frame.")
            return
        }

        // Handle optional image and audio URLs
        let imageUrl = selectedImageURL ?? nil
        let audioUrl = selectedAudioURL ?? nil

        // New Firestore schema
        let newQuestion: [String: Any] = [
            "text": questionText,
            "category": category.lowercased(),
            "subcategory": "familyAdded", // Example, can be dynamic
            "tag": "custom",
            "answerOptions": filledOptions,
            "answers": [],
            "correctAnswers": [],
            "image": imageUrl as Any,
            "audio": audioUrl as Any,
            "isAnswered": false,
            "askInterval": askInterval,
            "timeFrame": ["from": timeFrame.from, "to": timeFrame.to],
            "priority": 10,
            "isActive": true,
            "hint": questionText,
            "confidence": NSNull(),
            "hardness": 2,
            "questionType": "singleCorrect",
        ]

        let db = Firestore.firestore()

        // Save to user's personal question list
        db.collection("users").document(verifiedUserDocID).collection("questions").addDocument(data: newQuestion) { error in
            if let error = error {
                self.showAlert(title: "Error", message: "Failed to save question: \(error.localizedDescription)")
                return
            }

            // Save to shared familyAddedQuestions collection
            db.collection("familyAddedQuestions").addDocument(data: newQuestion) { familyError in
                if let familyError = familyError {
                    self.showAlert(title: "Error", message: "Question saved to user list, but failed to save in family collection: \(familyError.localizedDescription)")
                } else {
                    self.saveButton.setTitle("Saved", for: .normal)
                    self.saveButton.backgroundColor = .systemGreen
                    self.showAlert(title: "✅✅ Success", message: "Question saved successfully!!")
                }
            }
        }
    }

    // MARK: - Alert Helper Function

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Image Picker Logic

    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.isHidden = false
            cancelImageButton.isHidden = false
        }
        picker.dismiss(animated: true)
    }

    @objc private func removeImage() {
        imageView.image = nil
        imageView.isHidden = true
        cancelImageButton.isHidden = true
    }
}

// MARK: - Category Picker View Controller

class CategoryPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private let pickerView = UIPickerView()
    private let categories: [String]
    private let completion: (String) -> Void

    init(categories: [String], completion: @escaping (String) -> Void) {
        self.categories = categories
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        pickerView.delegate = self
        pickerView.dataSource = self

        let selectButton = UIButton(type: .system)
        selectButton.setTitle("Done", for: .normal)
        selectButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)

        selectButton.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pickerView)
        view.addSubview(selectButton)

        NSLayoutConstraint.activate([
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),

            selectButton.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc private func selectCategory() {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedCategory = categories[selectedRow]
        completion(selectedCategory)
        dismiss(animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { categories.count }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
}

#Preview { AddQuestionViewController(verifiedUserDocID: "DT7GZI") }
