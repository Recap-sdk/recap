//
//  AddQuestionViewController.swift
//
//  Created by admin70 on 13/11/24.
//

import UIKit
import FirebaseFirestore

class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Elements
    
    private let questionTypeSegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: ["Text Only", "Text & Image"])
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
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
        button.setTitle("Add Image", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private var optionTextFields: [UITextField] = {
        var textFields = [UITextField]()
        for i in 1...4 {
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
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Properties
    
    private var verifiedUserDocID: String = "userDocumentID" // Replace this with your actual user doc ID logic
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add Question"
        
        setupMainLayout()
        setupActions()
    }
    
    // MARK: - Layout Setup
    
    private func setupMainLayout() {
        view.addSubview(questionTypeSegment)
        view.addSubview(questionTextField)
        view.addSubview(saveButton)
        
        // Layout constraints for the main elements
        NSLayoutConstraint.activate([
            questionTypeSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            questionTextField.topAnchor.constraint(equalTo: questionTypeSegment.bottomAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Initial layout setup
        setupQuestionTypeLayout()
    }
    
    private func setupActions() {
        questionTypeSegment.addTarget(self, action: #selector(questionTypeChanged), for: .valueChanged)
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
    }
    
    private func setupQuestionTypeLayout() {
        // Clear the subviews that are specific to a layout type
        clearLayoutSubviews()

        if questionTypeSegment.selectedSegmentIndex == 0 {
            setupTextOnlyLayout()
        } else {
            setupTextAndImageLayout()
        }
    }
    
    private func setupTextOnlyLayout() {
        view.addSubview(questionTextField)
        optionTextFields.forEach { view.addSubview($0) }
        view.addSubview(saveButton)
        
        // Layout constraints for Text Only
        NSLayoutConstraint.activate([
            questionTextField.topAnchor.constraint(equalTo: questionTypeSegment.bottomAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        for (index, optionTextField) in optionTextFields.enumerated() {
            NSLayoutConstraint.activate([
                optionTextField.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: CGFloat(20 + index * 60)),
                optionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                optionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                optionTextField.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80), // Change the constant value here to move it upwards
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])

    }
    
    private func setupTextAndImageLayout() {
        // Add Image Button and Image View for text and image layout
        view.addSubview(imageView)
        view.addSubview(addImageButton)
        
        // Layout constraints for Text and Image
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            addImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addImageButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Option Text Fields and Save Button constraints will be the same as in TextOnly layout
        setupTextOnlyLayout()
    }

    // MARK: - Actions

    @objc private func saveQuestion() {
        let db = Firestore.firestore()
        
        // Gather data from the UI elements
        let questionText = questionTextField.text ?? ""
        let optionTexts = optionTextFields.map { $0.text ?? "" }
        
        // Ensure required fields are filled before saving
        guard !questionText.isEmpty, !optionTexts.contains(where: { $0.isEmpty }) else {
            print("Error: Please fill in all fields")
            return
        }
        
        // Add new question to Firestore
        let newQuestion: [String: Any] = [
            "text": questionText,
            "category": "recentMemory", // Updated category
            "subcategory": "health", // Updated subcategory
            "tag": "custom", // Updated tag
            "answerOptions": optionTexts,
            "image": NSNull(), // Add image logic if needed
            "isAnswered": false,
            "askInterval": 604800, // 1 week interval
            "lastAsked": NSNull(),
            "timesAsked": 0,
            "timesAnsweredCorrectly": 0
        ]
        
        // Save question to Firestore
        db.collection("Questions").addDocument(data: newQuestion) { error in
            if let error = error {
                print("Error saving question: \(error.localizedDescription)")
            } else {
                // Document was saved successfully, print the document ID
                let documentID = db.collection("Questions").document().documentID
                print("Question saved successfully. Document ID: \(documentID)")
                
                // Change UI to indicate success
                self.saveButton.setTitle("Saved", for: .normal)
                self.saveButton.backgroundColor = .systemGreen
                self.saveButton.setTitleColor(.white, for: .normal)
            }
        }
    }
    
    @objc func questionTypeChanged() {
        setupQuestionTypeLayout()
    }
    
    @objc func selectImage() {
        // Your code for selecting an image
    }
    
    func clearLayoutSubviews() {
        // Remove only specific subviews, not everything
        if questionTextField.isDescendant(of: view) {
            questionTextField.removeFromSuperview()
        }
        optionTextFields.forEach { $0.removeFromSuperview() }
        imageView.removeFromSuperview()
        addImageButton.removeFromSuperview()
    }
}
#Preview {
    AddQuestionViewController()
}
