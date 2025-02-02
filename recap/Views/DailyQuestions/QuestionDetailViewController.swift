import UIKit
import FirebaseFirestore

protocol QuestionDetailDelegate: AnyObject {
    func didSubmitAnswer(for question: Question)
}

class QuestionDetailViewController: UIViewController {

    weak var delegate: QuestionDetailDelegate?
    var question: Question?  // The question object passed from previous view
    var selectedOptionButton: UIButton?
    
    // Firestore reference
    private let db = Firestore.firestore()

    // UI Components
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let questionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let optionsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep going — each one sharpens your mind and warms hearts!"
        label.font = UIFont.italicSystemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        setupUI()
        fetchQuestionFromFirestore()  // Fetch question from Firestore
    }

    // MARK: - Fetch Question from Firestore
    private func fetchQuestionFromFirestore() {
        guard let questionId = question?.id else { return }

        db.collection("questions").document(questionId).getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error fetching question: \(error.localizedDescription)")
            } else if let document = document, document.exists, let data = document.data() {
                // Initialize the question with the data dictionary
                do {
                    self?.question = try Question(from: data as! Decoder)  // Ensure the initializer for Question exists
                    self?.setupUI()  // Update UI after fetching the question
                } catch {
                    print("Error initializing question: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        guard let question = question else { return }

        // Add subviews
        view.addSubview(questionLabel)
        
        // Safely unwrap and handle the image
        if let imageString = question.image, let imageData = Data(base64Encoded: imageString) {
            questionImageView.image = UIImage(data: imageData)
            view.addSubview(questionImageView)
        }

        view.addSubview(optionsContainer)
        view.addSubview(submitButton)
        view.addSubview(footerLabel)

        // Set question text
        questionLabel.text = question.text

        // Create option buttons
        optionsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }  // Clear old options
        for (index, option) in question.answerOptions.enumerated() {
            if index % 2 == 0 {
                let horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.spacing = 16
                horizontalStack.distribution = .fillEqually
                horizontalStack.translatesAutoresizingMaskIntoConstraints = false
                optionsContainer.addArrangedSubview(horizontalStack)
            }
            let button = createOptionButton(with: option)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            (optionsContainer.arrangedSubviews.last as? UIStackView)?.addArrangedSubview(button)
        }

        // Setup constraints
        setupConstraints()

        // Add submit button action
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        if question?.image != nil {
            NSLayoutConstraint.activate([
                questionImageView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
                questionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                questionImageView.widthAnchor.constraint(equalToConstant: 150),
                questionImageView.heightAnchor.constraint(equalToConstant: 150),

                optionsContainer.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 20)
            ])
        } else {
            NSLayoutConstraint.activate([
                optionsContainer.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20)
            ])
        }

        NSLayoutConstraint.activate([
            optionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            submitButton.topAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: 30),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 120),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            footerLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            footerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            footerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Create Option Button
    private func createOptionButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }

    // MARK: - Option Selection
    @objc private func optionSelected(_ sender: UIButton) {
        // Reset the previously selected button's appearance
        selectedOptionButton?.layer.borderColor = UIColor.lightGray.cgColor
        selectedOptionButton?.backgroundColor = .white

        // Update the selected button's appearance
        selectedOptionButton = sender
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
    }

    // MARK: - Submit Button Tapped
    @objc private func submitButtonTapped() {
        guard let selectedOptionButton = selectedOptionButton else { return }

        // Update button state
        submitButton.backgroundColor = .systemGreen
        submitButton.setTitle("Submitted", for: .normal)

        // Mark the question as answered and notify the delegate
        if var question = question {
            question.isAnswered = true
            delegate?.didSubmitAnswer(for: question)

            // Optionally, update Firestore here to mark the question as answered
            db.collection("questions").document(question.id ?? "<#default value#>").updateData([
                "isAnswered": true
            ]) { (error) in
                if let error = error {
                    print("Error updating question: \(error.localizedDescription)")
                } else {
                    print("Question successfully updated")
                }
            }
        }
    }
}
#Preview{ QuestionDetailViewController() }
