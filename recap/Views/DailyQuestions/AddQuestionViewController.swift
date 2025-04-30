import FirebaseFirestore
import FirebaseStorage
import UIKit

class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    var selectedImageURL: String?
    var selectedAudioURL: String?
    var selectedCategory: String?
    var selectedTimeFrame: String?

    private let categoryToolbar = UIToolbar()
    private let timeFrameToolbar = UIToolbar()

    // UI Components
    let categoryTextField = UITextField()
    let timeFrameTextField = UITextField()
    let questionTextField = UITextField()
    let imageView = UIImageView()
    let addImageButton = UIButton(type: .system)
    let cancelImageButton = UIButton(type: .system)
    var optionTextFields: [UITextField] = []
    let saveButton = UIButton(type: .system)
    let headerLabel = UILabel()
    
    // Word limit constants
    private let questionWordLimit = 50
    private let optionWordLimit = 20
    
    // Data
    let categories = ["Immediate", "Recent", "Remote"]
    let timeFrame = ["Morning", "Afternoon", "Evening", "Night"]

    let categoryPicker = UIPickerView()
    let timeFramePicker = UIPickerView()

    var verifiedUserDocID: String
    required init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupUI()
        setupLayout()
        setupActions()
        setupPickers()
    }
    
    private func setupView() {
//        view.backgroundColor = ColorTheme.background
        view.backgroundColor = .white
        title = "Add Question"
        
        // Setup navigation bar appearance
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = true
            navigationBar.tintColor = ColorTheme.primary
            
            // Remove navigation bar border
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }
        
        // Add gesture recognizer to dismiss keyboard
        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboard)
    }

    private func setupUI() {
        // Configure header label
        headerLabel.text = "Create a New Question"
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerLabel.textColor = AppColors.primaryTextColor
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure categoryTextField
        categoryTextField.placeholder = "Select Category"
        
        categoryTextField.textAlignment = .left
        styleTextField(categoryTextField)
        categoryTextField.inputView = categoryPicker
        categoryTextField.inputAccessoryView = categoryToolbar
        categoryTextField.textColor = AppColors.primaryTextColor
        
        // Add icon to category text field
        addLeftIconToTextField(categoryTextField, iconName: "folder.fill")
        
        // Configure timeFrameTextField
        timeFrameTextField.placeholder = "Select Time Frame"
        timeFrameTextField.textColor = AppColors.primaryTextColor
        timeFrameTextField.textAlignment = .left
        styleTextField(timeFrameTextField)
        timeFrameTextField.inputView = timeFramePicker
        timeFrameTextField.inputAccessoryView = timeFrameToolbar
        
        // Add icon to timeframe text field
        addLeftIconToTextField(timeFrameTextField, iconName: "clock.fill")

        // Configure questionTextField
        questionTextField.placeholder = "What did you eat? (max \(questionWordLimit) words)"
        questionTextField.backgroundColor = AppColors.cardBackgroundColor
        questionTextField.layer.cornerRadius = 15
        questionTextField.layer.borderWidth = 1
        questionTextField.layer.borderColor = AppColors.iconColor.cgColor
        questionTextField.textAlignment = .left
        questionTextField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionTextField.translatesAutoresizingMaskIntoConstraints = false
        questionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: questionTextField.frame.height))
        questionTextField.leftViewMode = .always
        questionTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: questionTextField.frame.height))
        questionTextField.rightViewMode = .always
        questionTextField.returnKeyType = .next
        
        // Add word limit to question field
        questionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // Configure imageView
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColors.secondaryTextColor
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = AppColors.iconColor.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true

        // Configure addImageButton
        addImageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        addImageButton.tintColor = AppColors.secondaryTextColor
        addImageButton.backgroundColor = UIColor.white
        addImageButton.layer.cornerRadius = 20

        addImageButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addImageButton.layer.shadowRadius = 4
        addImageButton.layer.shadowOpacity = 0.1
        addImageButton.translatesAutoresizingMaskIntoConstraints = false

        // Configure cancelImageButton
        cancelImageButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelImageButton.tintColor = UIColor.white
        cancelImageButton.backgroundColor = UIColor(white: 0, alpha: 0.6)
        cancelImageButton.layer.cornerRadius = 15
        cancelImageButton.translatesAutoresizingMaskIntoConstraints = false
        cancelImageButton.isHidden = true

        // Configure optionTextFields - in a 2x2 grid
        for i in 1...4 {
            let textField = UITextField()
            textField.placeholder = "Option \(i) (max \(optionWordLimit) words)"
            textField.backgroundColor = UIColor.white
            textField.layer.cornerRadius = 15
            textField.layer.borderWidth = 1
            textField.layer.borderColor = AppColors.secondaryButtonColor.cgColor
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
            textField.leftViewMode = .always
            textField.returnKeyType = .next
            textField.tag = i  // Set tag for identification
            
            // Add word limit to option field
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
//            // Add number badge
//            let badgeView = UIView()
//            badgeView.translatesAutoresizingMaskIntoConstraints = false
//            badgeView.backgroundColor = AppColors.iconColor
//            badgeView.layer.cornerRadius = 12
//
//            let numberLabel = UILabel()
//            numberLabel.translatesAutoresizingMaskIntoConstraints = false
//            numberLabel.text = "\(i)"
//            numberLabel.textColor = .white
//            numberLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
//            numberLabel.textAlignment = .center
//
//            badgeView.addSubview(numberLabel)
//
//            NSLayoutConstraint.activate([
//                numberLabel.centerXAnchor.constraint(equalTo: badgeView.centerXAnchor),
//                numberLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor)
//            ])
//
//            textField.leftView = badgeView
//            textField.leftViewMode = .always
//
//            NSLayoutConstraint.activate([
//                badgeView.widthAnchor.constraint(equalToConstant: 24),
//                badgeView.heightAnchor.constraint(equalToConstant: 24)
//            ])
            
            optionTextFields.append(textField)
        }

        // Configure saveButton
        saveButton.setTitle("Save Question", for: .normal)
        saveButton.backgroundColor = AppColors.primaryButtonColor
        saveButton.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add shadow to saveButton
        saveButton.layer.shadowColor = AppColors.primaryButtonColor.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 8
        saveButton.layer.shadowOpacity = 0.3

        // Setup toolbars
        categoryToolbar.sizeToFit()
        timeFrameToolbar.sizeToFit()
        categoryToolbar.barTintColor = AppColors.primaryTextColor
        timeFrameToolbar.barTintColor = AppColors.primaryTextColor

        let categoryDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryDonePressed))
        categoryDoneButton.tintColor = AppColors.primaryButtonColor
        let categoryFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        categoryToolbar.setItems([categoryFlexSpace, categoryDoneButton], animated: false)

        let timeFrameDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(timeFrameDonePressed))
        timeFrameDoneButton.tintColor = AppColors.primaryButtonColor
        let timeFrameFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        timeFrameToolbar.setItems([timeFrameFlexSpace, timeFrameDoneButton], animated: false)
    }
    
    private func styleTextField(_ textField: UITextField) {
        textField.backgroundColor = UIColor.white
        textField.textColor = AppColors.primaryTextColor
        textField.layer.cornerRadius = 15
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppColors.secondaryButtonColor.cgColor
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
        textField.rightViewMode = .always
        
        // Make sure it's enabled and user can interact with it
        textField.isUserInteractionEnabled = true
        textField.isEnabled = true
    }
    
    private func addLeftIconToTextField(_ textField: UITextField, iconName: String) {
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: textField.frame.height))
        let imageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 20, height: 20))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: iconName)
        imageView.tintColor = AppColors.iconColor
        iconContainer.addSubview(imageView)
        
        // Center the icon vertically
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: iconContainer.leadingAnchor, constant: 15),
            imageView.widthAnchor.constraint(equalToConstant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        textField.leftView = iconContainer
        textField.leftViewMode = .always
    }

    private func setupLayout() {
        view.addSubview(headerLabel)
        view.addSubview(questionTextField)
        view.addSubview(addImageButton)
        view.addSubview(imageView)
        view.addSubview(cancelImageButton)
        
        // Options grid layout - 2x2
        for i in 0..<optionTextFields.count {
            view.addSubview(optionTextFields[i])
        }
        
        // Category and TimeFrame in a stack
        let buttonStack = UIStackView(arrangedSubviews: [categoryTextField, timeFrameTextField])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 15
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonStack)
        
        view.addSubview(saveButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Header label
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Question text field
            questionTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 20),
            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionTextField.trailingAnchor.constraint(equalTo: addImageButton.leadingAnchor, constant: -15),
            questionTextField.heightAnchor.constraint(equalToConstant: 55),
            
            // Add image button
            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addImageButton.centerYAnchor.constraint(equalTo: questionTextField.centerYAnchor),
            addImageButton.widthAnchor.constraint(equalToConstant: 40),
            addImageButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Image view
            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            // Cancel image button
            cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
            cancelImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
            cancelImageButton.widthAnchor.constraint(equalToConstant: 30),
            cancelImageButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        // 2x2 grid layout for option textfields
        let gridSpacing: CGFloat = 15
        let topPadding: CGFloat = 20
        
        // First row (options 0 and 1)
        NSLayoutConstraint.activate([
            // First option (top left)
            optionTextFields[0].topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: topPadding),
            optionTextFields[0].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionTextFields[0].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -27.5),
            optionTextFields[0].heightAnchor.constraint(equalToConstant: 55),
            
            // Second option (top right)
            optionTextFields[1].topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: topPadding),
            optionTextFields[1].leadingAnchor.constraint(equalTo: optionTextFields[0].trailingAnchor, constant: gridSpacing),
            optionTextFields[1].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionTextFields[1].heightAnchor.constraint(equalToConstant: 55),
        ])
        
        // Second row (options 2 and 3)
        NSLayoutConstraint.activate([
            // Third option (bottom left)
            optionTextFields[2].topAnchor.constraint(equalTo: optionTextFields[0].bottomAnchor, constant: gridSpacing),
            optionTextFields[2].leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            optionTextFields[2].widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5, constant: -27.5),
            optionTextFields[2].heightAnchor.constraint(equalToConstant: 55),
            
            // Fourth option (bottom right)
            optionTextFields[3].topAnchor.constraint(equalTo: optionTextFields[1].bottomAnchor, constant: gridSpacing),
            optionTextFields[3].leadingAnchor.constraint(equalTo: optionTextFields[2].trailingAnchor, constant: gridSpacing),
            optionTextFields[3].trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            optionTextFields[3].heightAnchor.constraint(equalToConstant: 55),
        ])
        
        // Button stack and save button
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: optionTextFields[2].bottomAnchor, constant: 25),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 55),
            
            saveButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 250),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
        cancelImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
        
        // Add tap gestures to category and timeframe text fields to ensure they're clickable
        let categoryTapGesture = UITapGestureRecognizer(target: self, action: #selector(categoryTextFieldTapped))
        categoryTextField.addGestureRecognizer(categoryTapGesture)
        
        let timeFrameTapGesture = UITapGestureRecognizer(target: self, action: #selector(timeFrameTextFieldTapped))
        timeFrameTextField.addGestureRecognizer(timeFrameTapGesture)
    }
    
    @objc private func categoryTextFieldTapped() {
        categoryTextField.becomeFirstResponder()
    }
    
    @objc private func timeFrameTextFieldTapped() {
        timeFrameTextField.becomeFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        let wordLimit = textField == questionTextField ? questionWordLimit : optionWordLimit
        let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        
        if words.count > wordLimit {
            // Trim to word limit
            let trimmedText = words[0..<wordLimit].joined(separator: " ")
            textField.text = trimmedText
            
            // Give visual feedback
//            textField.layer.borderColor = UIColor.systemRed.cgColor
            textField.layer.borderWidth = 2
            
            // Reset border after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.3) {
//                    textField.layer.borderColor = ColorTheme.secondary.cgColor
//                    textField.layer.borderWidth = 1
                }
            }
        }
    }
    
    private func setupPickers() {
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        timeFramePicker.delegate = self
        timeFramePicker.dataSource = self
    }

    @objc func categoryDonePressed() {
        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
        selectedCategory = categories[selectedRow]
        categoryTextField.text = selectedCategory
        view.endEditing(true) // Dismiss the picker
    }

    @objc func timeFrameDonePressed() {
        let selectedRow = timeFramePicker.selectedRow(inComponent: 0)
        selectedTimeFrame = timeFrame[selectedRow]
        timeFrameTextField.text = selectedTimeFrame
        view.endEditing(true) // Dismiss the picker
    }

    @objc private func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func animateTextField(_ textField: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            textField.transform = CGAffineTransform(translationX: 10, y: 0)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                textField.transform = CGAffineTransform(translationX: -10, y: 0)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    textField.transform = CGAffineTransform.identity
                })
            })
        })
        
        // Highlight border in red
//        let originalBorderColor = textField.layer.borderColor
//        textField.layer.borderColor = UIColor.systemRed.cgColor
        textField.layer.borderWidth = 2
        
        // Reset border after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.3) {
//                textField.layer.borderColor = originalBorderColor
                textField.layer.borderWidth = 1
            }
        }
    }
    
    func animateSaveButton() {
        // Scale animation
        UIView.animate(withDuration: 0.15, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.saveButton.transform = CGAffineTransform.identity
            })
        })
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.isHidden = false
            cancelImageButton.isHidden = false
            
            // Add fade-in animation
            imageView.alpha = 0
            cancelImageButton.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1
                self.cancelImageButton.alpha = 1
            }
        }
        picker.dismiss(animated: true)
    }

    @objc private func removeImage() {
        // Add fade-out animation
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.alpha = 0
            self.cancelImageButton.alpha = 0
        }, completion: { _ in
            self.imageView.image = nil
            self.imageView.isHidden = true
            self.cancelImageButton.isHidden = true
        })
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == categoryPicker {
            return categories.count
        } else {
            return timeFrame.count
        }
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == categoryPicker {
            return categories[row]
        } else {
            return timeFrame[row]
        }
    }
    
    // Custom styling for picker view
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = AppColors.iconColor
        
        if pickerView == categoryPicker {
            label.text = categories[row]
        } else {
            label.text = timeFrame[row]
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
}


#Preview {
    AddQuestionViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
}

//import FirebaseFirestore
//import FirebaseStorage
//import UIKit
//
//class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
//    var selectedImageURL: String?
//    var selectedAudioURL: String?
//    var selectedCategory: String?
//    var selectedTimeFrame: String?
//
//    private let categoryToolbar = UIToolbar()
//    private let timeFrameToolbar = UIToolbar()
//
//    let categoryTextField = UITextField() // Replaced UIButton with UITextField
//    let timeFrameTextField = UITextField() // Replaced UIButton with UITextField
//    let questionTextField = UITextField()
//    let imageView = UIImageView()
//    let addImageButton = UIButton(type: .system)
//    let cancelImageButton = UIButton(type: .system)
//    var optionTextFields: [UITextField] = []
//    let saveButton = UIButton(type: .system)
//    let categories = ["Immediate", "Recent", "Remote"]
//    let timeFrame = ["Morning", "Afternoon", "Evening", "Night"]
//
//    let categoryPicker = UIPickerView()
//    let timeFramePicker = UIPickerView()
//
//    var verifiedUserDocID: String
//    required init(verifiedUserDocID: String) {
//        self.verifiedUserDocID = verifiedUserDocID
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        title = "Add Question"
//
//        setupUI()
//        setupLayout()
//
//        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
//        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
//        cancelImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
//
//        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(dismissKeyboard)
//
//        categoryPicker.delegate = self
//        categoryPicker.dataSource = self
//        timeFramePicker.delegate = self
//        timeFramePicker.dataSource = self
//    }
//
//    private func setupUI() {
//        // Configure categoryTextField
//        categoryTextField.placeholder = "Select Category"
//        categoryTextField.textAlignment = .center
//        categoryTextField.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
//        categoryTextField.textColor = Constants.ButtonStyle.DefaultButtonTextColor
//        categoryTextField.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
//        categoryTextField.font = Constants.ButtonStyle.DefaultButtonFont
//        categoryTextField.translatesAutoresizingMaskIntoConstraints = false
//        categoryTextField.inputView = categoryPicker // Set inputView to categoryPicker
//        categoryTextField.inputAccessoryView = categoryToolbar // Set inputAccessoryView to categoryToolbar
//
//        // Configure timeFrameTextField
//        timeFrameTextField.placeholder = "Select Time Frame"
//        timeFrameTextField.textAlignment = .center
//        timeFrameTextField.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
//        timeFrameTextField.textColor = Constants.ButtonStyle.DefaultButtonTextColor
//        timeFrameTextField.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
//        timeFrameTextField.font = Constants.ButtonStyle.DefaultButtonFont
//        timeFrameTextField.translatesAutoresizingMaskIntoConstraints = false
//        timeFrameTextField.inputView = timeFramePicker // Set inputView to timeFramePicker
//        timeFrameTextField.inputAccessoryView = timeFrameToolbar // Set inputAccessoryView to timeFrameToolbar
//
//        // Configure questionTextField
//        questionTextField.placeholder = "What did you eat?"
//        questionTextField.backgroundColor = UIColor.systemGray6
//        questionTextField.layer.cornerRadius = 10
//        questionTextField.textAlignment = .center
//        questionTextField.font = UIFont.systemFont(ofSize: 26)
//        questionTextField.translatesAutoresizingMaskIntoConstraints = false
//
//        // Configure imageView
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.backgroundColor = UIColor.systemGray5
//        imageView.layer.cornerRadius = 10
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.isHidden = true
//
//        // Configure addImageButton
//        addImageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
//        addImageButton.tintColor = .black
//        addImageButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Configure cancelImageButton
//        cancelImageButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
//        cancelImageButton.tintColor = .red
//        cancelImageButton.backgroundColor = .white
//        cancelImageButton.layer.cornerRadius = 12
//        cancelImageButton.translatesAutoresizingMaskIntoConstraints = false
//        cancelImageButton.isHidden = true
//
//        // Configure optionTextFields
//        for i in 1 ... 4 {
//            let textField = UITextField()
//            textField.placeholder = "Option \(i)"
//            textField.backgroundColor = UIColor.systemGray6
//            textField.layer.cornerRadius = 10
//            textField.font = UIFont.systemFont(ofSize: 20)
//            textField.translatesAutoresizingMaskIntoConstraints = false
//            optionTextFields.append(textField)
//        }
//
//        // Configure saveButton
//        saveButton.setTitle("Save", for: .normal)
//        saveButton.backgroundColor = Constants.ButtonStyle.DefaultButtonBackgroundColor
//        saveButton.setTitleColor(Constants.ButtonStyle.DefaultButtonTextColor, for: .normal)
//        saveButton.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
//        saveButton.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
//        saveButton.translatesAutoresizingMaskIntoConstraints = false
//
//        // Setup toolbars
//        categoryToolbar.sizeToFit()
//        timeFrameToolbar.sizeToFit()
//
//        let categoryDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(categoryDonePressed))
//        let categoryFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        categoryToolbar.setItems([categoryFlexSpace, categoryDoneButton], animated: false)
//
//        let timeFrameDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(timeFrameDonePressed))
//        let timeFrameFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        timeFrameToolbar.setItems([timeFrameFlexSpace, timeFrameDoneButton], animated: false)
//    }
//
//    @objc func categoryDonePressed() {
//        let selectedRow = categoryPicker.selectedRow(inComponent: 0)
//        selectedCategory = categories[selectedRow]
//        categoryTextField.text = selectedCategory
//        view.endEditing(true) // Dismiss the picker
//    }
//
//    @objc func timeFrameDonePressed() {
//        let selectedRow = timeFramePicker.selectedRow(inComponent: 0)
//        selectedTimeFrame = timeFrame[selectedRow]
//        timeFrameTextField.text = selectedTimeFrame
//        view.endEditing(true) // Dismiss the picker
//    }
//
//    private func setupLayout() {
//        view.addSubview(questionTextField)
//        view.addSubview(addImageButton)
//        view.addSubview(imageView)
//        optionTextFields.forEach { view.addSubview($0) }
//        view.addSubview(saveButton)
//        view.addSubview(cancelImageButton)
//
//        NSLayoutConstraint.activate([
//            questionTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            questionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            questionTextField.trailingAnchor.constraint(equalTo: addImageButton.leadingAnchor, constant: -10),
//            questionTextField.heightAnchor.constraint(equalToConstant: 50),
//
//            addImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            addImageButton.centerYAnchor.constraint(equalTo: questionTextField.centerYAnchor),
//            addImageButton.widthAnchor.constraint(equalToConstant: 40),
//            addImageButton.heightAnchor.constraint(equalToConstant: 40),
//
//            imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: 10),
//            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            imageView.heightAnchor.constraint(equalToConstant: 200),
//
//            cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: -10),
//            cancelImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
//            cancelImageButton.widthAnchor.constraint(equalToConstant: 24),
//            cancelImageButton.heightAnchor.constraint(equalToConstant: 24),
//        ])
//
//        for (index, optionTextField) in optionTextFields.enumerated() {
//            NSLayoutConstraint.activate([
//                optionTextField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: CGFloat(10 + index * 55)),
//                optionTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//                optionTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//                optionTextField.heightAnchor.constraint(equalToConstant: 50),
//            ])
//        }
//
//        let buttonStack = UIStackView(arrangedSubviews: [categoryTextField, timeFrameTextField])
//        buttonStack.axis = .horizontal
//        buttonStack.spacing = 20
//        buttonStack.alignment = .fill
//        buttonStack.distribution = .fillEqually
//        buttonStack.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(buttonStack)
//
//        NSLayoutConstraint.activate([
//            buttonStack.topAnchor.constraint(equalTo: optionTextFields.last!.bottomAnchor, constant: 30),
//            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            buttonStack.heightAnchor.constraint(equalToConstant: 50),
//
//            saveButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
//            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            saveButton.widthAnchor.constraint(equalToConstant: 250),
//            saveButton.heightAnchor.constraint(equalToConstant: 50),
//        ])
//    }
//
//    @objc private func selectImage() {
//        let picker = UIImagePickerController()
//        picker.delegate = self
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary
//        present(picker, animated: true)
//    }
//
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
//            imageView.image = selectedImage
//            imageView.isHidden = false
//            cancelImageButton.isHidden = false
//        }
//        picker.dismiss(animated: true)
//    }
//
//    @objc private func removeImage() {
//        imageView.image = nil
//        imageView.isHidden = true
//        cancelImageButton.isHidden = true
//    }
//
//    // MARK: - UIPickerViewDataSource
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if pickerView == categoryPicker {
//            return categories.count
//        } else {
//            return timeFrame.count
//        }
//    }
//
//    // MARK: - UIPickerViewDelegate
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if pickerView == categoryPicker {
//            return categories[row]
//        } else {
//            return timeFrame[row]
//        }
//    }
//}
