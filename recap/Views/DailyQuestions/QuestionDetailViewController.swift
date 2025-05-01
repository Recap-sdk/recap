//import UIKit
//import FirebaseFirestore
//
//protocol QuestionDetailDelegate: AnyObject {
//    func didSubmitAnswer(for question: Question)
//}
//
//class QuestionDetailViewController: UIViewController {
//
//    weak var delegate: QuestionDetailDelegate?
//    var question: Question?
//    var selectedOptionButton: UIButton?
//    var verifiedUserDocID: String
//    
//    init(verifiedUserDocID: String) {
//        self.verifiedUserDocID = verifiedUserDocID
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    // Firestore reference
//    private let db = Firestore.firestore()
//
//    // UI Components
//    private let questionLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.boldSystemFont(ofSize: 22)
//        label.textColor = .black
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let questionImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let optionsContainer: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.spacing = 16
//        stackView.translatesAutoresizingMaskIntoConstraints = false
//        return stackView
//    }()
//
//    private let submitButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Submit", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
//        button.setTitleColor(.white, for: .normal)
//        button.backgroundColor = UIColor.systemBlue
//        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let footerLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Keep going — each one helps your loved ones"
//        label.font = UIFont.italicSystemFont(ofSize: 14)
//        label.textColor = .gray
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
//        setupUI()
////        fetchQuestionFromFirestore()  // Fetch question from Firestore
//    }
//
//    // MARK: - Fetch Question from Firestore
////    private func fetchQuestionFromFirestore() {
////        guard let questionId = question?.id else { return }
////
////        db.collection("questions").document(questionId).getDocument { [weak self] (document, error) in
////            if let error = error {
////                print("Error fetching question: \(error.localizedDescription)")
////            } else if let document = document, document.exists, let data = document.data() {
////                // Initialize the question with the data dictionary
////                do {
////                    self?.question = try Question(from: data as! Decoder)  // Ensure the initializer for Question exists
////                    self?.setupUI()  // Update UI after fetching the question
////                } catch {
////                    print("Error initializing question: \(error.localizedDescription)")
////                }
////            }
////        }
////    }
//
//    // MARK: - UI Setup
//    private func setupUI() {
//        guard let question = question else { return }
//
//        // Add subviews
//        view.addSubview(questionLabel)
//        
//        // Safely unwrap and handle the image
//        if let imageString = question.image, let imageData = Data(base64Encoded: imageString) {
//            questionImageView.image = UIImage(data: imageData)
//            view.addSubview(questionImageView)
//        }
//
//        view.addSubview(optionsContainer)
//        view.addSubview(submitButton)
//        view.addSubview(footerLabel)
//
//        // Set question text
//        questionLabel.text = question.text
//
//        // Create option buttons
//        optionsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }  // Clear old options
//        for (index, option) in question.answerOptions.enumerated() {
//            if index % 2 == 0 {
//                let horizontalStack = UIStackView()
//                horizontalStack.axis = .horizontal
//                horizontalStack.spacing = 16
//                horizontalStack.distribution = .fillEqually
//                horizontalStack.translatesAutoresizingMaskIntoConstraints = false
//                optionsContainer.addArrangedSubview(horizontalStack)
//            }
//            let button = createOptionButton(with: option)
//            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
//            (optionsContainer.arrangedSubviews.last as? UIStackView)?.addArrangedSubview(button)
//        }
//
//        // Setup constraints
//        setupConstraints()
//
//        // Add submit button action
//        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
//    }
//
//    // MARK: - Setup Constraints
//    private func setupConstraints() {
//            NSLayoutConstraint.activate([
//                questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//                questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//                questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//            ])
//        
//            if question?.image != nil {
//                NSLayoutConstraint.activate([
//                    questionImageView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
//                    questionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                    questionImageView.widthAnchor.constraint(equalToConstant: 150),
//                    questionImageView.heightAnchor.constraint(equalToConstant: 150),
//
//                    optionsContainer.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 40)
//                ])
//            } else {
//                NSLayoutConstraint.activate([
//                    optionsContainer.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 70)
//                ])
//            }
//            NSLayoutConstraint.activate([
//                optionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//                optionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//            ])
//
//            NSLayoutConstraint.activate([
//                submitButton.bottomAnchor.constraint(equalTo: footerLabel.topAnchor, constant: -20),
//                submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//                submitButton.widthAnchor.constraint(equalToConstant: 120),
//                submitButton.heightAnchor.constraint(equalToConstant: 50),
//
//                footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//                footerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//                footerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
//            ])
//        }
//
//    // MARK: - Create Option Button
//    private func createOptionButton(with title: String) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        button.setTitleColor(.black, for: .normal)
//        button.backgroundColor = .white
//        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.lightGray.cgColor
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        return button
//    }
//
//    // MARK: - Option Selection
//    @objc private func optionSelected(_ sender: UIButton) {
//        // Reset the previously selected button's appearance
//        selectedOptionButton?.layer.borderColor = UIColor.lightGray.cgColor
//        selectedOptionButton?.backgroundColor = .white
//
//        // Update the selected button's appearance
//        selectedOptionButton = sender
//        sender.layer.borderColor = UIColor.systemBlue.cgColor
//        sender.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
//    }
//
//    @objc private func submitButtonTapped() {
//
//        guard let selectedOptionButton = selectedOptionButton, var question = question else { return }
//
//        let selectedAnswer = selectedOptionButton.title(for: .normal) ?? ""
//
//        // Mark the question as answered
//        question.isAnswered = true
//
//        // Update button state
//        submitButton.backgroundColor = .systemGreen
//        submitButton.setTitle("Submitted", for: .normal)
//
//        // Notify delegate that the answer was submitted
//        delegate?.didSubmitAnswer(for: question)
//
//        // Update Firestore (Original CODE1 Firestore Update)
//        db.collection("questions").document(question.id ?? "<#default value#>").updateData([
//            "isAnswered": true
//        ]) { (error) in
//            if let error = error {
//                print("Error updating question: \(error.localizedDescription)")
//            } else {
//                print("Question successfully updated")
//            }
//        }
//
//        let questionsFetcher = QuestionsManager(verifiedUserDocID: verifiedUserDocID)
//
//        let userQuestionRef = db.collection("users")
//            .document(questionsFetcher.verifiedUserDocID)
//            .collection("questions")
//            .document(question.id ?? "")
//
//        userQuestionRef.setData([
//            "correctAnswers": [selectedAnswer],
//            "isAnswered": true // Update the isAnswered field in Firestore
//        ], merge: true) { error in
//            if let error = error {
//                print("Error updating correct answer: \(error.localizedDescription)")
//            } else {
//                print("Correct answer successfully saved in Firestore.")
//            }
//        }
//    }
//
//}
//#Preview{
//    QuestionDetailViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
//}

import UIKit
import FirebaseFirestore

protocol QuestionDetailDelegate: AnyObject {
    func didSubmitAnswer(for question: Question)
}

class QuestionDetailViewController: UIViewController {
    weak var delegate: QuestionDetailDelegate?
    var question: Question?
    var selectedOptionButton: UIButton?
    var verifiedUserDocID: String
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Firestore reference
    private let db = Firestore.firestore()
    
    // UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let questionCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.shadowRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = AppColors.iconColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let optionsContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColors.iconColor
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep going — each one helps your loved ones"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = AppColors.iconColor.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let questionCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.iconColor.withAlphaComponent(0.7)
        label.textAlignment = .right
//        label.text = "Question 1 of 1"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Store original button appearance
    private struct ButtonAppearance {
        let backgroundColor: UIColor
        let borderColor: CGColor
        let textColor: UIColor
    }
    
    private var originalButtonAppearance = [UIButton: ButtonAppearance]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupNavigationBar()
        setupUI()
    }
    
    private func setupBackground() {
        view.backgroundColor = AppColors.cardBackgroundColor
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = AppColors.iconColor
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: AppColors.secondaryTextColor,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        title = "Daily Questions"
    }
    
    private func setupUI() {
        guard let question = question else { return }
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(questionCountLabel)
        contentView.addSubview(questionCard)
        questionCard.addSubview(questionLabel)
        questionCard.addSubview(questionImageView)
        questionCard.addSubview(optionsContainer)
        contentView.addSubview(submitButton)
        contentView.addSubview(footerLabel)
        
        // Set question text and image
        questionLabel.text = question.text
        if let imageString = question.image, let imageData = Data(base64Encoded: imageString) {
            questionImageView.image = UIImage(data: imageData)
            questionImageView.isHidden = false
        } else {
            questionImageView.isHidden = true
        }
        
        // Clear existing options
        optionsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Setup options in a single-column layout
        for option in question.answerOptions {
            let button = createOptionButton(with: option)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsContainer.addArrangedSubview(button)
        }
        
        // Setup constraints
        setupConstraints()
        
        // Add submit button action
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        // Initial submit button state
        submitButton.alpha = 0.7
        submitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Question Count Label
            questionCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            questionCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Question Card
            questionCard.topAnchor.constraint(equalTo: questionCountLabel.bottomAnchor, constant: 24),
            questionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Question Label
            questionLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20),
            
            // Question Image
            questionImageView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            questionImageView.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            questionImageView.widthAnchor.constraint(equalToConstant: 150),
            questionImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Options Container
            optionsContainer.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 24),
            optionsContainer.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            optionsContainer.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20),
            optionsContainer.bottomAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: -24),
            
            // Submit Button
            submitButton.topAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: 32),
            submitButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 180),
            submitButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Footer Label
            footerLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            footerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            footerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func createOptionButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.highlightColor.cgColor
        
        originalButtonAppearance[button] = ButtonAppearance(
            backgroundColor: .white,
            borderColor: AppColors.highlightColor.cgColor,
            textColor: AppColors.primaryButtonTextColor
        )
        
        button.contentHorizontalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }
    
    @objc private func optionSelected(_ sender: UIButton) {
        if let previousButton = selectedOptionButton,
           let originalAppearance = originalButtonAppearance[previousButton] {
            previousButton.layer.borderColor = originalAppearance.borderColor
            previousButton.backgroundColor = originalAppearance.backgroundColor
            previousButton.setTitleColor(originalAppearance.textColor, for: .normal)
        }
        
        selectedOptionButton = sender
        sender.layer.borderColor = AppColors.primaryButtonColor.cgColor
        sender.backgroundColor = AppColors.primaryButtonColor.withAlphaComponent(0.1)
        sender.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.submitButton.alpha = 1.0
            self.submitButton.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func submitButtonTapped() {
        guard let selectedOptionButton = selectedOptionButton, var question = question else { return }
        
        let selectedAnswer = selectedOptionButton.title(for: .normal) ?? ""
        question.isAnswered = true
        
        submitButton.backgroundColor = AppColors.iconColor
        submitButton.setTitle("Submitted", for: .normal)
        
        delegate?.didSubmitAnswer(for: question)
        
        db.collection("questions").document(question.id ?? "<#default value#>").updateData([
            "isAnswered": true
        ]) { (error) in
            if let error = error {
                print("Error updating question: \(error.localizedDescription)")
            } else {
                print("Question successfully updated")
            }
        }
        
        let questionsFetcher = QuestionsManager(verifiedUserDocID: verifiedUserDocID)
        let userQuestionRef = db.collection("users")
            .document(questionsFetcher.verifiedUserDocID)
            .collection("questions")
            .document(question.id ?? "")
        
        userQuestionRef.setData([
            "correctAnswers": [selectedAnswer],
            "isAnswered": true
        ], merge: true) { error in
            if let error = error {
                print("Error updating correct answer: \(error.localizedDescription)")
            } else {
                print("Correct answer successfully saved in Firestore.")
            }
        }
    }
}

#Preview {
    QuestionDetailViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
}
