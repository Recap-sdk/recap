//
//  PatientQuestionViewController.swift
//  recap
//
//  Created by s1834 on 08/02/25.
//

#Preview{
    PatientQuestionViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
}

import UIKit
import FirebaseFirestore

protocol PatientQuestionsDelegate: AnyObject {
    func didSubmitAnswer(for question: Question)
}

class PatientQuestionViewController: UIViewController, NextQuestionCardViewDelegate {
    func didTapGoHome() {
        dismissCard()
        moveToNextQuestion()
        navigationController?.popToRootViewController(animated: true)
    }
    
    func didTapNextQuestion() {
        dismissCard()
        moveToNextQuestion()
    }
    
    func didTapPlayGame() {
        dismissCard()
        moveToNextQuestion()
        let playGameVC = PlayGameViewController()
        navigationController?.pushViewController(playGameVC, animated: true)
    }
    
    func didTapReadArticle() {
        dismissCard()
        moveToNextQuestion()
        let articleVC = ArticleTableViewController()
        navigationController?.pushViewController(articleVC, animated: true)
    }
    
    weak var delegate: PatientQuestionsDelegate?
    var question: Question?
    var selectedOptionButton: UIButton?
    var verifiedUserDocID: String
    var currentQuestionIndex = 0
    var questions: [Question] = []
    
    let db = Firestore.firestore()
    
    private var blurEffectView: UIVisualEffectView?
    private var nextQuestionCardView: NextQuestionCardView?
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    // Grid container for options
    private let optionsGridContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Full width container for the last option when needed
    private let fullWidthOptionContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let leftColumnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let rightColumnStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = AppColors.iconColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        return button
    }()

    private let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "Keep going — each one sharpens your mind and warms hearts!"
        label.font = UIFont.italicSystemFont(ofSize: 16)
        label.textColor = AppColors.iconColor.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .bar)
        progress.trackTintColor = AppColors.cardBackgroundColor
        progress.progressTintColor = AppColors.highlightColor
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    private let questionCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.iconColor.withAlphaComponent(0.7)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Constraints that need to be activated/deactivated
    private var fullWidthOptionTopConstraint: NSLayoutConstraint?
    private var fullWidthOptionHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.cardBackgroundColor
        setupNavigationBar()
        setupUI()
        fetchQuestionsFromFirestore()
    }
//    
    
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupBackground()  // Use this method instead of direct assignment
//        setupNavigationBar()
//        setupUI()
//        fetchQuestionsFromFirestore()
//    }
//
//    private func setupBackground() {
//        // Remove any existing gradient layers first
//        view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
//        
//        // For all devices, use gradient background
//        let gradientLayer = AppColors.createAppBackgroundGradientLayer()
//        gradientLayer.frame = view.bounds
//        view.layer.insertSublayer(gradientLayer, at: 0)
//    }
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        // Update gradient layer frame when view size changes
//        if let gradientLayer = view.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
//            gradientLayer.frame = view.bounds
//        }
//    }
//    
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
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(questionCountLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(questionCard)
        questionCard.addSubview(questionLabel)
        questionCard.addSubview(questionImageView)
        
        // Setup the two-column grid for options
        questionCard.addSubview(optionsGridContainer)
        optionsGridContainer.addSubview(leftColumnStackView)
        optionsGridContainer.addSubview(rightColumnStackView)
        optionsGridContainer.addSubview(fullWidthOptionContainer)
        
        contentView.addSubview(submitButton)
        contentView.addSubview(footerLabel)
        
        submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        setupConstraints()
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
            
            // Progress View
            progressView.topAnchor.constraint(equalTo: questionCountLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            progressView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            progressView.heightAnchor.constraint(equalToConstant: 8),
            
            // Question Card
            questionCard.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 24),
            questionCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            questionCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Question Label inside Card
            questionLabel.topAnchor.constraint(equalTo: questionCard.topAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20),
            
            // Question Image inside Card
            questionImageView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            questionImageView.centerXAnchor.constraint(equalTo: questionCard.centerXAnchor),
            questionImageView.widthAnchor.constraint(equalToConstant: 150),
            questionImageView.heightAnchor.constraint(equalToConstant: 150),
            
            // Options Grid Container
            optionsGridContainer.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 24),
            optionsGridContainer.leadingAnchor.constraint(equalTo: questionCard.leadingAnchor, constant: 20),
            optionsGridContainer.trailingAnchor.constraint(equalTo: questionCard.trailingAnchor, constant: -20),
            optionsGridContainer.bottomAnchor.constraint(equalTo: questionCard.bottomAnchor, constant: -24),
            
            // Left Column Stack View
            leftColumnStackView.topAnchor.constraint(equalTo: optionsGridContainer.topAnchor),
            leftColumnStackView.leadingAnchor.constraint(equalTo: optionsGridContainer.leadingAnchor),
            leftColumnStackView.widthAnchor.constraint(equalTo: optionsGridContainer.widthAnchor, multiplier: 0.48),
            
            // Right Column Stack View
            rightColumnStackView.topAnchor.constraint(equalTo: optionsGridContainer.topAnchor),
            rightColumnStackView.trailingAnchor.constraint(equalTo: optionsGridContainer.trailingAnchor),
            rightColumnStackView.widthAnchor.constraint(equalTo: optionsGridContainer.widthAnchor, multiplier: 0.48),
            
            // Full Width Option Container (for last option when needed)
            fullWidthOptionContainer.leadingAnchor.constraint(equalTo: optionsGridContainer.leadingAnchor),
            fullWidthOptionContainer.trailingAnchor.constraint(equalTo: optionsGridContainer.trailingAnchor),
            
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
        
        // Create constraints that will be activated/deactivated as needed
        fullWidthOptionTopConstraint = fullWidthOptionContainer.topAnchor.constraint(equalTo: leftColumnStackView.bottomAnchor, constant: 12)
        fullWidthOptionHeightConstraint = fullWidthOptionContainer.heightAnchor.constraint(equalToConstant: 0)
        
        // Initially deactivate these constraints
        fullWidthOptionTopConstraint?.isActive = false
        fullWidthOptionHeightConstraint?.isActive = true
    }
    
//    private func createOptionButton(with title: String, isFullWidth: Bool = false) -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle(title, for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
//        button.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
//        button.backgroundColor = .white
//        button.layer.cornerRadius = 16
//        button.layer.borderWidth = 1.5
//        button.layer.borderColor = AppColors.highlightColor.cgColor
    
    
    
    private func createOptionButton(with title: String, isFullWidth: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        button.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.highlightColor.cgColor
        
        // Store original appearance
        originalButtonAppearance[button] = ButtonAppearance(
            backgroundColor: .white,
            borderColor: AppColors.highlightColor.cgColor,
            textColor: AppColors.primaryButtonTextColor
        )
        
        
        // Center align text for better appearance in grid layout
        button.contentHorizontalAlignment = .center
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.numberOfLines = 0 // Allow multiple lines for longer options
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        // Adjust height for grid layout
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        
        // Add subtle shadow for depth
//        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }
    
    private struct ButtonAppearance {
        let backgroundColor: UIColor
        let borderColor: CGColor
        let textColor: UIColor
    }

    private var originalButtonAppearance = [UIButton: ButtonAppearance]()
    
    
    @objc private func optionSelected(_ sender: UIButton) {
        // Reset previous selection to original appearance
        if let previousButton = selectedOptionButton,
           let originalAppearance = originalButtonAppearance[previousButton] {
            previousButton.layer.borderColor = originalAppearance.borderColor
            previousButton.backgroundColor = originalAppearance.backgroundColor
            previousButton.setTitleColor(originalAppearance.textColor, for: .normal)
        }
        
        // Set new selection
        selectedOptionButton = sender
        sender.layer.borderColor = AppColors.primaryButtonColor.cgColor
        sender.backgroundColor = AppColors.primaryButtonColor.withAlphaComponent(0.1)
        sender.setTitleColor(AppColors.primaryButtonTextColor, for: .normal)
        
        // Enable submit button with animation
        UIView.animate(withDuration: 0.3) {
            self.submitButton.alpha = 1.0
            self.submitButton.transform = CGAffineTransform.identity
        }
    }
    @objc private func submitAnswer() {
        guard let selectedAnswer = selectedOptionButton?.title(for: .normal) else {
            // Show a subtle animation to indicate no selection
            UIView.animate(withDuration: 0.3, animations: {
                self.submitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.submitButton.transform = CGAffineTransform.identity
                }
            }
            return
        }

        var currentQuestion = questions[currentQuestionIndex]
        guard let questionID = currentQuestion.id else {
            print("❌❌ Error: Question ID is missing.")
            return
        }

        currentQuestion.isAnswered = true
        currentQuestion.answers.append(selectedAnswer)

        // Show loading state on button
        submitButton.setTitle("Submitting...", for: .normal)
        submitButton.isEnabled = false
        
        let questionRef = db.collection("users").document(verifiedUserDocID).collection("questions").document(questionID)
        questionRef.updateData([
            "isAnswered": true,
            "answers": currentQuestion.answers,
            "lastAsked": Date()
        ]) { [weak self] error in
            guard let self = self else { return }
            
            // Reset button state
            self.submitButton.setTitle("Submit", for: .normal)
            self.submitButton.isEnabled = true
            
            if let error = error {
                print("❌❌ Error updating question: \(error.localizedDescription)")
                // Show error briefly
                let originalColor = self.submitButton.backgroundColor
                UIView.animate(withDuration: 0.3, animations: {
                    self.submitButton.backgroundColor = UIColor.systemRed
                }) { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.submitButton.backgroundColor = originalColor
                    }
                }
            } else {
                self.updateStreakAndAnalytics()
                self.showNextQuestionCard()
            }
        }
    }
    
    private func showNextQuestionCard() {
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView?.frame = view.bounds
        blurEffectView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView?.alpha = 0
        
        // Create card view
        nextQuestionCardView = NextQuestionCardView()
        nextQuestionCardView?.delegate = self
        nextQuestionCardView?.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        nextQuestionCardView?.center = view.center
        nextQuestionCardView?.alpha = 0
        nextQuestionCardView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        if let blurView = blurEffectView, let cardView = nextQuestionCardView {
            view.addSubview(blurView)
            view.addSubview(cardView)
            
            // Animate in
            UIView.animate(withDuration: 0.3) {
                blurView.alpha = 1
                cardView.alpha = 1
                cardView.transform = .identity
            }
        }
    }
    
    private func dismissCard() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView?.alpha = 0
            self.nextQuestionCardView?.alpha = 0
            self.nextQuestionCardView?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.blurEffectView?.removeFromSuperview()
            self.nextQuestionCardView?.removeFromSuperview()
        }
    }
    
    func showNoQuestionsReadyAlert() {
        let successVC = SuccessQuestionsViewController()
        successVC.modalPresentationStyle = .overFullScreen
        successVC.modalTransitionStyle = .crossDissolve
        
        // Set the exit action
        successVC.onExitTapped = { [weak self] in
            self?.exitQuestionFlow()
        }
        
        present(successVC, animated: true, completion: nil)
    }

    // MARK: - Exit the Question Flow
    private func exitQuestionFlow() {
        navigationController?.popViewController(animated: true)
    }
    
    func moveToNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < questions.count {
            displayQuestion(questions[currentQuestionIndex])
            updateProgressBar()
        } else {
            showNoQuestionsReadyAlert()
        }
    }
    
    func updateProgressBar() {
        guard !questions.isEmpty else { return }
        let progress = Float(currentQuestionIndex + 1) / Float(questions.count)
        
        // Animate progress update
        UIView.animate(withDuration: 0.5) {
            self.progressView.setProgress(progress, animated: true)
        }
        
        // Update question count label
        questionCountLabel.text = "Question \(currentQuestionIndex + 1) of \(questions.count)"
    }
    
    // Updated displayQuestion function to handle 2-column layout with the last option spanning both columns if needed
    func displayQuestion(_ question: Question) {
        // Clear existing options
        self.leftColumnStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.rightColumnStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.fullWidthOptionContainer.subviews.forEach { $0.removeFromSuperview() }
        
        // Deactivate constraints for full width option
        fullWidthOptionTopConstraint?.isActive = false
        fullWidthOptionHeightConstraint?.isActive = true
        
        // Animation for question change
        UIView.transition(with: questionCard, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.questionLabel.text = question.text
            
            if let imageString = question.image, let imageData = Data(base64Encoded: imageString) {
                self.questionImageView.image = UIImage(data: imageData)
                self.questionImageView.isHidden = false
            } else {
                self.questionImageView.isHidden = true
            }
            
            let options = question.answerOptions
            let optionCount = options.count
            
            // Handle distribution of options
            if optionCount % 2 == 1 && optionCount > 1 {
                // Odd number of options - last one will span full width
                let pairsCount = (optionCount - 1) / 2
                
                // Add pairs to left and right columns
                for i in 0..<pairsCount {
                    let leftButton = self.createOptionButton(with: options[i * 2])
                    let rightButton = self.createOptionButton(with: options[i * 2 + 1])
                    
                    leftButton.addTarget(self, action: #selector(self.optionSelected(_:)), for: .touchUpInside)
                    rightButton.addTarget(self, action: #selector(self.optionSelected(_:)), for: .touchUpInside)
                    
                    self.leftColumnStackView.addArrangedSubview(leftButton)
                    self.rightColumnStackView.addArrangedSubview(rightButton)
                }
                
                // Add last option as full width
                let lastOptionButton = self.createOptionButton(with: options.last!, isFullWidth: true)
                lastOptionButton.addTarget(self, action: #selector(self.optionSelected(_:)), for: .touchUpInside)
                
                self.fullWidthOptionContainer.addSubview(lastOptionButton)
                
                // Configure full width button
                NSLayoutConstraint.activate([
                    lastOptionButton.topAnchor.constraint(equalTo: self.fullWidthOptionContainer.topAnchor),
                    lastOptionButton.leadingAnchor.constraint(equalTo: self.fullWidthOptionContainer.leadingAnchor),
                    lastOptionButton.trailingAnchor.constraint(equalTo: self.fullWidthOptionContainer.trailingAnchor),
                    lastOptionButton.bottomAnchor.constraint(equalTo: self.fullWidthOptionContainer.bottomAnchor)
                ])
                
                // Activate full-width container constraints
                self.fullWidthOptionTopConstraint?.isActive = true
                self.fullWidthOptionHeightConstraint?.isActive = false
                
                // Update bottom constraints
                NSLayoutConstraint.deactivate([
                    self.leftColumnStackView.bottomAnchor.constraint(equalTo: self.optionsGridContainer.bottomAnchor),
                    self.rightColumnStackView.bottomAnchor.constraint(equalTo: self.optionsGridContainer.bottomAnchor)
                ])
                
                self.fullWidthOptionContainer.bottomAnchor.constraint(equalTo: self.optionsGridContainer.bottomAnchor).isActive = true
                
            } else {
                // Even number of options or just a single option
                for (index, option) in options.enumerated() {
                    let button = self.createOptionButton(with: option)
                    button.addTarget(self, action: #selector(self.optionSelected(_:)), for: .touchUpInside)
                    
                    if index % 2 == 0 {
                        // Even indices go to left column
                        self.leftColumnStackView.addArrangedSubview(button)
                    } else {
                        // Odd indices go to right column
                        self.rightColumnStackView.addArrangedSubview(button)
                    }
                }
                
                // For even number of options, make sure both columns have the same bottom constraint
                self.leftColumnStackView.bottomAnchor.constraint(equalTo: self.optionsGridContainer.bottomAnchor).isActive = true
                self.rightColumnStackView.bottomAnchor.constraint(equalTo: self.optionsGridContainer.bottomAnchor).isActive = true
            }
        }, completion: nil)
        
        // Reset selection state
        selectedOptionButton = nil
        
        // Disable submit button initially
        submitButton.alpha = 0.7
        submitButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

}

