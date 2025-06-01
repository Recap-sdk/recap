import FirebaseFirestore
import FirebaseStorage
import UIKit


// Extend UIButton for easy state handling (optional but helpful)
extension UIButton {
    func setTitleColor(_ color: UIColor?, for state: UIControl.State, placeholder: String?) {
        if title(for: .normal) == placeholder {
            setTitleColor(.placeholderText, for: state)
        } else {
            setTitleColor(color, for: state)
        }
    }
}

// Inherit only necessary protocols
class AddQuestionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var selectedImageURL: String?
     var selectedAudioURL: String? // Remove if not used
    var selectedCategory: String?
    var selectedTimeFrame: String?

    // --- UI Components ---
    let scrollView = UIScrollView()
    let contentView = UIView()

    // *** Replaced TextFields with Buttons for Menu ***
    let categoryButton = UIButton(type: .system)
    let timeFrameButton = UIButton(type: .system)
    let categoryPlaceholder = "Category"
    let timeFramePlaceholder = "Time Frame"


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

    // Data (Keep data arrays)
    let categories = ["Immediate", "Recent", "Remote"]
    let timeFrame = ["Morning", "Afternoon", "Evening", "Night"]

    // *** Removed Pickers and Toolbars ***
    // let categoryPicker = UIPickerView()
    // let timeFramePicker = UIPickerView()
    // private let categoryToolbar = UIToolbar()
    // private let timeFrameToolbar = UIToolbar()

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
        setupUI() // Will configure buttons and menus
        setupLayout()
        setupActions()
        // *** Removed setupPickers() ***
        setupKeyboardObservers()
    }

    deinit {
        removeKeyboardObservers()
    }

    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        title = "Add Question"

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = true
            navigationBar.tintColor = ColorTheme.primary
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.shadowImage = UIImage()
        }

        let dismissKeyboard = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboard.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboard)
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true

        headerLabel.text = "Create a New Question"
        headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerLabel.textColor = UIColor.label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        // --- Configure Category Button ---
        styleMenuButton(categoryButton, placeholder: categoryPlaceholder)
        addLeftIconToButton(categoryButton, iconName: "folder.fill")
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        setupCategoryMenu() // Setup the menu actions

        // --- Configure TimeFrame Button ---
        styleMenuButton(timeFrameButton, placeholder: timeFramePlaceholder)
        addLeftIconToButton(timeFrameButton, iconName: "clock.fill")
        timeFrameButton.translatesAutoresizingMaskIntoConstraints = false
        setupTimeFrameMenu() // Setup the menu actions


        // Configure questionTextField (remains the same)
        questionTextField.placeholder = "What did you eat? (max \(questionWordLimit) words)"
        questionTextField.backgroundColor = AppColors.cardBackgroundColor
        questionTextField.layer.cornerRadius = 15
        questionTextField.layer.borderWidth = 1
        questionTextField.layer.borderColor = AppColors.iconColor.cgColor
        questionTextField.textAlignment = .left
        questionTextField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        questionTextField.textColor = UIColor.label
        questionTextField.translatesAutoresizingMaskIntoConstraints = false
        questionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: questionTextField.frame.height))
        questionTextField.leftViewMode = .always
        questionTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: questionTextField.frame.height))
        questionTextField.rightViewMode = .always
        questionTextField.returnKeyType = .next
        questionTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        // ImageView, Add/Cancel Image Button configuration (remains the same)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = AppColors.secondaryTextColor
        imageView.layer.cornerRadius = 15
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = AppColors.iconColor.withAlphaComponent(0.3).cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true

        addImageButton.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        addImageButton.tintColor = AppColors.secondaryTextColor
        addImageButton.backgroundColor = UIColor.systemBackground // Use systemBackground
        addImageButton.layer.cornerRadius = 20
        addImageButton.layer.shadowColor = UIColor.black.cgColor
        addImageButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addImageButton.layer.shadowRadius = 4
        addImageButton.layer.shadowOpacity = 0.1
        addImageButton.translatesAutoresizingMaskIntoConstraints = false

        cancelImageButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelImageButton.tintColor = UIColor.white
        cancelImageButton.backgroundColor = UIColor(white: 0, alpha: 0.6)
        cancelImageButton.layer.cornerRadius = 15
        cancelImageButton.translatesAutoresizingMaskIntoConstraints = false
        cancelImageButton.isHidden = true

        // Option TextFields (remains the same)
        for i in 1 ... 4 {
            let textField = UITextField()
            textField.placeholder = "Option \(i) (max \(optionWordLimit) words)"
            textField.backgroundColor = UIColor.secondarySystemBackground
            textField.textColor = UIColor.label
            textField.layer.cornerRadius = 15
            textField.layer.borderWidth = 1
            textField.layer.borderColor = AppColors.secondaryButtonColor.cgColor
            textField.font = UIFont.systemFont(ofSize: 16)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: textField.frame.height))
            textField.leftViewMode = .always
            textField.returnKeyType = .next
            textField.tag = i
            textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            optionTextFields.append(textField)
        }

        // Save Button (remains the same)
        saveButton.setTitle("Save Question", for: .normal)
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(UIColor.white, for: .normal)
        saveButton.layer.cornerRadius = 25
        saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.layer.shadowColor = AppColors.primaryButtonColor.cgColor
        saveButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        saveButton.layer.shadowRadius = 8
        saveButton.layer.shadowOpacity = 0.3

        // *** Removed Toolbar setup ***
    }

    private func styleMenuButton(_ button: UIButton, placeholder: String) {
        button.backgroundColor = UIColor.secondarySystemBackground
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.iconColor.withAlphaComponent(0.7).cgColor
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.contentHorizontalAlignment = .left // Align text left

        // Set initial title and placeholder color
        button.setTitle(placeholder, for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)

        // Add a subtle chevron down icon to indicate dropdown
         let chevronImage = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
         button.setImage(chevronImage, for: .normal)
         button.semanticContentAttribute = .forceRightToLeft // Puts image on the right
         button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15) // Padding for chevron
         button.tintColor = AppColors.iconColor // Color for chevron
    }

     // --- Add Icon to Left of Button Text ---
    private func addLeftIconToButton(_ button: UIButton, iconName: String) {
         // Set the button's primary image (used on the right by styleMenuButton) temporarily to nil
         let rightImage = button.image(for: .normal)
         button.setImage(nil, for: .normal) // Clear right image temporarily

         // Configure the left icon
        let iconImage = UIImage(systemName: iconName)?
             .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)) // Adjust size/weight as needed
             .withRenderingMode(.alwaysTemplate) // Ensure tint color is applied

        // Calculate needed padding
         let iconLeftPadding: CGFloat = 15
         let spacingBetweenIconAndText: CGFloat = 10
         let totalLeftPadding = iconLeftPadding + (iconImage?.size.width ?? 0) + spacingBetweenIconAndText

         // Set content insets: top, left (for icon + text), bottom, right (handled by chevron insets)
         button.contentEdgeInsets = UIEdgeInsets(top: 0, left: iconLeftPadding, bottom: 0, right: 0) // Base left padding for icon

         // Set title insets: top, left (space after icon), bottom, right
         button.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacingBetweenIconAndText, bottom: 0, right: -spacingBetweenIconAndText) // Shift title right, adjust right to counter content inset

         // Create an image view for the left icon and add it as a subview
         // This is often more reliable for precise positioning than button.setImage
         let iconImageView = UIImageView(image: iconImage)
         iconImageView.tintColor = AppColors.iconColor
         iconImageView.translatesAutoresizingMaskIntoConstraints = false
         button.addSubview(iconImageView)

         NSLayoutConstraint.activate([
             iconImageView.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: iconLeftPadding),
             iconImageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
             iconImageView.widthAnchor.constraint(equalToConstant: iconImage?.size.width ?? 20),
             iconImageView.heightAnchor.constraint(equalToConstant: iconImage?.size.height ?? 20)
         ])

         // Restore the right image (chevron)
         button.setImage(rightImage, for: .normal)
     }


    // --- Setup UIMenu for Category ---
    private func setupCategoryMenu() {
        let actions = categories.map { category in
            UIAction(title: category, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedCategory = category
                self.categoryButton.setTitle(category, for: .normal)
                self.categoryButton.setTitleColor(.label, for: .normal) // Set to normal text color
                // Optional: Reset border if it was highlighted as invalid
                if self.categoryButton.layer.borderColor == UIColor.systemRed.cgColor {
                     self.resetButtonBorder(self.categoryButton)
                }
            })
        }

        categoryButton.menu = UIMenu(title: "Select Category", children: actions)
        categoryButton.showsMenuAsPrimaryAction = true
    }

    // --- Setup UIMenu for Time Frame ---
    private func setupTimeFrameMenu() {
        let actions = timeFrame.map { time in
            UIAction(title: time, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTimeFrame = time
                self.timeFrameButton.setTitle(time, for: .normal)
                self.timeFrameButton.setTitleColor(.label, for: .normal) // Set to normal text color
                 // Optional: Reset border if it was highlighted as invalid
                 if self.timeFrameButton.layer.borderColor == UIColor.systemRed.cgColor {
                     self.resetButtonBorder(self.timeFrameButton)
                 }
            })
        }

        timeFrameButton.menu = UIMenu(title: "Select Time Frame", children: actions)
        timeFrameButton.showsMenuAsPrimaryAction = true
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // ContentView constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        // Add elements to contentView
        contentView.addSubview(headerLabel)
        contentView.addSubview(questionTextField)
        contentView.addSubview(addImageButton)
        contentView.addSubview(imageView)
        contentView.addSubview(cancelImageButton)
        optionTextFields.forEach { contentView.addSubview($0) }

        // *** Use Buttons in StackView ***
        let buttonStack = UIStackView(arrangedSubviews: [categoryButton, timeFrameButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 15
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStack)

        contentView.addSubview(saveButton)

        // --- Constraints relative to ContentView ---
         let horizontalPadding: CGFloat = 20
         let verticalSpacing: CGFloat = 20
         let gridSpacing: CGFloat = 15
         let elementHeight: CGFloat = 55 // Consistent height for text fields/buttons

         NSLayoutConstraint.activate([
             // Header label
             headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing),
             headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),

             // Question text field & Add Image Button (Same as before)
             questionTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: verticalSpacing),
             questionTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             questionTextField.trailingAnchor.constraint(equalTo: addImageButton.leadingAnchor, constant: -15),
             questionTextField.heightAnchor.constraint(equalToConstant: elementHeight),

             addImageButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
             addImageButton.centerYAnchor.constraint(equalTo: questionTextField.centerYAnchor),
             addImageButton.widthAnchor.constraint(equalToConstant: 40),
             addImageButton.heightAnchor.constraint(equalToConstant: 40),

             // Image view & Cancel Button (Same as before)
             imageView.topAnchor.constraint(equalTo: questionTextField.bottomAnchor, constant: verticalSpacing),
             imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
             imageView.heightAnchor.constraint(equalToConstant: 200),

             cancelImageButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
             cancelImageButton.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -10),
             cancelImageButton.widthAnchor.constraint(equalToConstant: 30),
             cancelImageButton.heightAnchor.constraint(equalToConstant: 30),

             // Option TextFields Grid (Same as before, check width constraint carefully)
             optionTextFields[0].topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: verticalSpacing),
             optionTextFields[0].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             optionTextFields[0].widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -(horizontalPadding + gridSpacing / 2)), // Adjusted constant
             optionTextFields[0].heightAnchor.constraint(equalToConstant: elementHeight),

             optionTextFields[1].topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: verticalSpacing),
             optionTextFields[1].leadingAnchor.constraint(equalTo: optionTextFields[0].trailingAnchor, constant: gridSpacing),
             optionTextFields[1].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
             optionTextFields[1].heightAnchor.constraint(equalToConstant: elementHeight),

             optionTextFields[2].topAnchor.constraint(equalTo: optionTextFields[0].bottomAnchor, constant: gridSpacing),
             optionTextFields[2].leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             optionTextFields[2].widthAnchor.constraint(equalTo: optionTextFields[0].widthAnchor),
             optionTextFields[2].heightAnchor.constraint(equalToConstant: elementHeight),

             optionTextFields[3].topAnchor.constraint(equalTo: optionTextFields[1].bottomAnchor, constant: gridSpacing),
             optionTextFields[3].leadingAnchor.constraint(equalTo: optionTextFields[2].trailingAnchor, constant: gridSpacing),
             optionTextFields[3].trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
             optionTextFields[3].heightAnchor.constraint(equalToConstant: elementHeight),


             // *** Button stack (Category/TimeFrame) constraints ***
             buttonStack.topAnchor.constraint(equalTo: optionTextFields[2].bottomAnchor, constant: 25),
             buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
             buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
             buttonStack.heightAnchor.constraint(equalToConstant: elementHeight), // Use consistent height


             // Save button (Same as before)
             saveButton.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
             saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
             saveButton.widthAnchor.constraint(equalToConstant: 250),
             saveButton.heightAnchor.constraint(equalToConstant: 50),

             // Bottom constraint for scroll content
             saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalSpacing)
         ])
    }


    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveQuestion), for: .touchUpInside)
        cancelImageButton.addTarget(self, action: #selector(removeImage), for: .touchUpInside)
        // *** Removed picker-related taps ***
    }

    // Word limit checking (remains the same)
     @objc func textFieldDidChange(_ textField: UITextField) {
         guard let text = textField.text else { return }
         let isQuestionField = textField == questionTextField
         let wordLimit = isQuestionField ? questionWordLimit : optionWordLimit

         let words = text.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

         if words.count > wordLimit {
             let trimmedText = words[0 ..< wordLimit].joined(separator: " ")
             textField.text = trimmedText
             highlightInvalidField(textField) // Use the common highlight method
         } else {
             // Reset border if it was previously highlighted for word limit
             if textField.layer.borderColor == UIColor.systemRed.cgColor {
                 resetTextFieldBorder(textField)
             }
         }
     }

     // Reset border for TextFields
      private func resetTextFieldBorder(_ textField: UITextField) {
          let originalBorderColor = (textField == questionTextField) ? AppColors.iconColor.cgColor : AppColors.secondaryButtonColor.cgColor
          let originalBorderWidth: CGFloat = 1.0

          UIView.animate(withDuration: 0.3) {
              textField.layer.borderColor = originalBorderColor
              textField.layer.borderWidth = originalBorderWidth
          }
      }

      // Reset border for Buttons
      private func resetButtonBorder(_ button: UIButton) {
          let originalBorderColor = AppColors.iconColor.withAlphaComponent(0.7).cgColor
          let originalBorderWidth: CGFloat = 1.5

          UIView.animate(withDuration: 0.3) {
              button.layer.borderColor = originalBorderColor
              button.layer.borderWidth = originalBorderWidth
          }
      }


    @objc private func selectImage() { /* ... same as before ... */
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // --- Input Validation & Animation ---
    private func validateInputs() -> Bool {
        var firstInvalidField: UIView? = nil

        // Reset borders first
        let textFieldsToReset = [questionTextField] + optionTextFields
        textFieldsToReset.forEach { resetTextFieldBorder($0) }
        resetButtonBorder(categoryButton)
        resetButtonBorder(timeFrameButton)


        // Check Question
        if questionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            highlightInvalidField(questionTextField)
            firstInvalidField = questionTextField
        }

        // Check Options (e.g., require at least 2)
        let validOptions = optionTextFields.filter { !($0.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) }
        if validOptions.count < 2 {
            optionTextFields.forEach { textField in
                if textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                    if firstInvalidField == nil { firstInvalidField = textField }
                    highlightInvalidField(textField)
                }
            }
            // If fields are empty but count<2 wasn't triggered (e.g. 0 or 1 filled) highlight first empty one
            if firstInvalidField == nil, let firstEmpty = optionTextFields.first(where: { $0.text?.isEmpty ?? true }) {
                 highlightInvalidField(firstEmpty)
                 firstInvalidField = firstEmpty
            } else if firstInvalidField == nil && validOptions.isEmpty { // Highlight first if all empty
                highlightInvalidField(optionTextFields[0])
                firstInvalidField = optionTextFields[0]
            }
        }


        // *** Check Category using selectedCategory variable ***
        if selectedCategory == nil {
            highlightInvalidField(categoryButton) // Highlight the button
            if firstInvalidField == nil { firstInvalidField = categoryButton }
        }

        // *** Check Time Frame using selectedTimeFrame variable ***
        if selectedTimeFrame == nil {
            highlightInvalidField(timeFrameButton) // Highlight the button
            if firstInvalidField == nil { firstInvalidField = timeFrameButton }
        }

        if let invalidField = firstInvalidField {
            scrollView.scrollRectToVisible(invalidField.frame.insetBy(dx: 0, dy: -20), animated: true) // Scroll with padding
            return false
        }

        return true
    }

    // Generic highlight function works for UIView (Button, TextField)
    private func highlightInvalidField(_ field: UIView) {
        field.layer.borderColor = UIColor.systemRed.cgColor
        field.layer.borderWidth = 2.0
        animateViewShake(field)
    }

    func animateViewShake(_ viewToShake: UIView) { /* ... same as before ... */
         let animation = CABasicAnimation(keyPath: "position")
         animation.duration = 0.07
         animation.repeatCount = 3
         animation.autoreverses = true
         animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
         animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
         viewToShake.layer.add(animation, forKey: "position")
     }


    func animateSaveButton() { /* ... same as before ... */
        UIView.animate(withDuration: 0.15, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.saveButton.transform = CGAffineTransform.identity
            })
        })
    }

    private func showAlert(title: String, message: String) { /* ... same as before ... */
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) { /* ... same as before ... */
        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            imageView.image = selectedImage
            imageView.isHidden = false
            cancelImageButton.isHidden = false

            imageView.alpha = 0
            cancelImageButton.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.imageView.alpha = 1
                self.cancelImageButton.alpha = 1
            }
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { /* ... same as before ... */
         picker.dismiss(animated: true)
     }

    @objc private func removeImage() { /* ... same as before ... */
        UIView.animate(withDuration: 0.3, animations: {
            self.imageView.alpha = 0
            self.cancelImageButton.alpha = 0
        }, completion: { _ in
            self.imageView.image = nil
            self.imageView.isHidden = true
            self.cancelImageButton.isHidden = true
            self.selectedImageURL = nil
        })
    }

    // *** Removed UIPickerView Delegate/DataSource Methods ***

    // MARK: - Keyboard Handling
    // setupKeyboardObservers, removeKeyboardObservers, keyboardWillShow, keyboardWillHide
    // remain the same as in the previous version with ScrollView.

     private func setupKeyboardObservers() {
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     private func removeKeyboardObservers() {
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
     }

     @objc private func keyboardWillShow(notification: NSNotification) {
         guard let userInfo = notification.userInfo,
               let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
               let activeField = UIResponder.currentFirstResponder as? UIView else { return } // Find active field

         let keyboardHeight = keyboardFrame.height
         let bottomInset = keyboardHeight - view.safeAreaInsets.bottom
         scrollView.contentInset.bottom = bottomInset
         scrollView.scrollIndicatorInsets.bottom = bottomInset

        // Scroll the active text field to be visible
         var viewFrameInScrollView = contentView.convert(activeField.frame, from: activeField.superview)
         viewFrameInScrollView.size.height += 10 // Add a little padding below the field
         scrollView.scrollRectToVisible(viewFrameInScrollView, animated: true)

     }

     @objc private func keyboardWillHide(notification: NSNotification) {
         scrollView.contentInset.bottom = 0
         scrollView.scrollIndicatorInsets.bottom = 0
     }

    // MARK: - Firebase Operations (Placeholders)
     func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
          // Simulate network delay
          DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
             print("Simulating image upload...")
             // --- Replace with actual Firebase Storage upload ---
             guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                 DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data."])))
                 }
                 return
             }

             let storageRef = Storage.storage().reference()
             let filename = "\(UUID().uuidString).jpg"
             let imageRef = storageRef.child("question_images/\(self.verifiedUserDocID)/\(filename)")

             imageRef.putData(imageData, metadata: nil) { metadata, error in
                 if let error = error {
                    DispatchQueue.main.async { completion(.failure(error)) }
                    return
                 }
                 imageRef.downloadURL { url, error in
                    DispatchQueue.main.async {
                         if let error = error {
                             completion(.failure(error))
                         } else if let url = url {
                            print("Simulated image upload successful: \(url)")
                             completion(.success(url))
                         } else {
                            completion(.failure(NSError(domain: "AppError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Could not get download URL."])))
                         }
                    }
                 }
             }
             // --- End of Firebase upload code ---
         }
     }


    func saveDataToFirestore(question: String, category: String, timeFrame: String, options: [String], imageURL: String?, audioURL: String?) {
        // Simulate network delay
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Delay after potential image upload finishes
             print("Simulating Firestore save...")
             // --- Replace with actual Firestore save ---
             let db = Firestore.firestore()
             let userQuestionsCollection = db.collection("VerifiedUsers").document(self.verifiedUserDocID).collection("Questions")

             var data: [String: Any] = [
                 "questionText": question,
                 "category": category,
                 "timeFrame": timeFrame,
                 "options": options,
                 "createdAt": Timestamp(date: Date()),
                 "userId": self.verifiedUserDocID
             ]
             if let url = imageURL { data["imageURL"] = url }
             // if let url = audioURL { data["audioURL"] = url } // If audio implemented

             userQuestionsCollection.addDocument(data: data) { [weak self] error in
                 // self?.hideActivityIndicator() // Hide indicator
                 if let error = error {
                     print("Firestore save error: \(error.localizedDescription)")
                     self?.showAlert(title: "Save Failed", message: "Could not save the question: \(error.localizedDescription)")
                 } else {
                     print("Question saved successfully!")
                     self?.showAlert(title: "Success", message: "Question saved successfully.")
                     self?.clearFields() // Clear form on success
                 }
             }
              // --- End of Firestore save code ---
         }
     }

     func clearFields() {
         questionTextField.text = ""
         optionTextFields.forEach { $0.text = "" }
         // Reset buttons to placeholder state
         categoryButton.setTitle(categoryPlaceholder, for: .normal)
         categoryButton.setTitleColor(.placeholderText, for: .normal)
         timeFrameButton.setTitle(timeFramePlaceholder, for: .normal)
         timeFrameButton.setTitleColor(.placeholderText, for: .normal)

         selectedCategory = nil
         selectedTimeFrame = nil
         removeImage()
         // Clear selectedAudioURL if used

         // Reset borders
         resetTextFieldBorder(questionTextField)
         optionTextFields.forEach { resetTextFieldBorder($0) }
         resetButtonBorder(categoryButton)
         resetButtonBorder(timeFrameButton)

         // Scroll back to top
         scrollView.setContentOffset(.zero, animated: true)
     }
}


// Helper to get the current first responder
extension UIResponder {
    private struct Static {
        static weak var responder: UIResponder?
    }

    static var currentFirstResponder: UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
}
