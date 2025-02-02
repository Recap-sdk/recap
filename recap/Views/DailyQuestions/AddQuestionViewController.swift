import UIKit

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
        
        // Initial layout setup
        setupQuestionTypeLayout()
    }
    
    private func setupActions() {
        questionTypeSegment.addTarget(self, action: #selector(questionTypeChanged), for: .valueChanged)
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
    }
    
    private func setupQuestionTypeLayout() {
        clearAllSubviews()
        
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
            questionTypeSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            questionTextField.topAnchor.constraint(equalTo: questionTypeSegment.bottomAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        setupTextOnlyOptions()
    }
    
    private func setupTextAndImageLayout() {
        view.addSubview(questionTextField)
        view.addSubview(imageView)
        view.addSubview(addImageButton)
        optionTextFields.forEach { view.addSubview($0) }
        view.addSubview(saveButton)
        
        // Layout constraints for Text & Image
        imageView.isHidden = false
        addImageButton.isHidden = false
        
        NSLayoutConstraint.activate([
            questionTypeSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionTypeSegment.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTypeSegment.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            questionTextField.topAnchor.constraint(equalTo: questionTypeSegment.bottomAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            questionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addImageButton.heightAnchor.constraint(equalToConstant: 40),
            addImageButton.widthAnchor.constraint(equalToConstant: 120),
            
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        setupTextAndImageOptions()
    }
    
    private func setupTextOnlyOptions() {
        let spacing: CGFloat = 20
        var previousView: UIView = questionTextField
        
        for option in optionTextFields {
            NSLayoutConstraint.activate([
                option.topAnchor.constraint(equalTo: previousView.bottomAnchor, constant: spacing),
                option.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                option.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                option.heightAnchor.constraint(equalToConstant: 40)
            ])
            previousView = option
        }
    }
    
    private func setupTextAndImageOptions() {
        let rows = 2
        let columns = 2
        let spacing: CGFloat = 10
        let widthMultiplier: CGFloat = 0.45
        
        for (index, option) in optionTextFields.enumerated() {
            let row = index / columns
            let column = index % columns
            
            NSLayoutConstraint.activate([
                option.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: CGFloat(row) * 50 + spacing),
                option.leadingAnchor.constraint(equalTo: column == 0 ? view.leadingAnchor : optionTextFields[index - 1].trailingAnchor, constant: spacing),
                option.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMultiplier),
                option.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func questionTypeChanged() {
        setupQuestionTypeLayout()
    }
    
    @objc private func selectImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc private func saveQuestion() {
        guard let title = questionTextField.text, !title.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter a question title", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // MARK: - Commented Out Data Handling
        /*
        let options = optionTextFields.map { $0.text ?? "" }
        
        // CoreData saving
        let context = PersistenceController.shared.persistentContainer.viewContext
        
        // Initialize newQuestion
        let newQuestion = Question(context: context)
        newQuestion.text = title
        newQuestion.answerOptions = options
        newQuestion.isAnswered = false
        newQuestion.image = imageView.image?.jpegData(compressionQuality: 0.8) // Store image data
        
        // Save the context
        do {
            try context.save()
            print("Question saved successfully.")
            
            // Sending the new question (this is safe because newQuestion is already initialized)
            sendNewQuestion(newQuestion)
            
            dismiss(animated: true, completion: nil)
        } catch {
            print("Failed to save question: \(error.localizedDescription)")
        }
        */
    }
    
    // MARK: - Helper Methods
    
    private func clearAllSubviews() {
        questionTextField.removeFromSuperview()
        imageView.removeFromSuperview()
        addImageButton.removeFromSuperview()
        optionTextFields.forEach { $0.removeFromSuperview() }
        saveButton.removeFromSuperview()
    }
    
    // MARK: - Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.isHidden = false
        }
    }
}
