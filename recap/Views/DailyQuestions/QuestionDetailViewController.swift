


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
    
    private let optionsContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        optionsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Setup options in a 2x2 grid layout
        setupOptionsGrid(with: question.answerOptions)
        
        // Setup constraints
        setupConstraints()
        
        // Add submit button action
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        
        // Initial submit button state
        submitButton.alpha = 0.7
        submitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }
    
    private func setupOptionsGrid(with options: [String]) {
        let columns = 2
        let spacing: CGFloat = 12
        let additionalRightPadding: CGFloat = 10 // Add extra padding on the right side
        
        for (index, option) in options.enumerated() {
            let row = index / columns
            let column = index % columns
            
            let button = createOptionButton(with: option)
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            optionsContainer.addSubview(button)
            
            // Calculate position in grid
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Adjust button width to leave more space on the right
            let totalHorizontalPadding = 40 + additionalRightPadding // 20 (left) + 20 (right) + additionalRightPadding
            let buttonWidth = (UIScreen.main.bounds.width - totalHorizontalPadding - spacing) / 2
            
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: buttonWidth),
                button.heightAnchor.constraint(equalToConstant: 60),
                button.topAnchor.constraint(equalTo: optionsContainer.topAnchor, constant: CGFloat(row) * (60 + spacing)),
                button.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: CGFloat(column) * (buttonWidth + spacing))
            ])
        }
        
        // Set height of optionsContainer based on number of rows
        let rows = (options.count + columns - 1) / columns
        let containerHeight = CGFloat(rows) * 60 + CGFloat(rows - 1) * spacing
        optionsContainer.heightAnchor.constraint(equalToConstant: containerHeight).isActive = true
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
            optionsContainer.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20), // Ensure it stays within card
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

//#Preview {
//    QuestionDetailViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
//}
