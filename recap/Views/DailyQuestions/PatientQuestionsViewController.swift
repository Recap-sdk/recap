//
//  PatientQuestionsViewController.swift
//  recap
//
//  Created by user@47 on 08/02/25.
//

import UIKit
import FirebaseFirestore

protocol PatientQuestionsDelegate: AnyObject {
    func didSubmitAnswer(for question: Question)
}

class PatientQuestionsViewController: UIViewController {

    weak var delegate: PatientQuestionsDelegate?
    var question: Question?
    var selectedOptionButton: UIButton?
    var verifiedUserDocID: String
    var currentQuestionIndex = 0
    var questions: [Question] = [] // To hold fetched questions
    
    private let db = Firestore.firestore()

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        fetchQuestionsFromFirestore() // Fetch all questions for the user
    }

    // MARK: - Fetch Questions from Firestore
    
    private func fetchQuestionsFromFirestore() {
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")
        
        userQuestionsRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("🔥 Error fetching questions: \(error.localizedDescription)")
                return
            }

            // Extract data and ensure each question has an ID
            self.questions = snapshot?.documents.compactMap { document in
                var question = try? document.data(as: Question.self)
                question?.id = document.documentID  // Ensure the question has its Firestore document ID
                return question
            } ?? []

            if self.questions.isEmpty {
                print("⚠️ No questions found.")
                return
            }

            self.sortQuestions()
            self.askAllQuestions()
        }
    }


    
    private func askAllQuestions() {
        print("🟢 Asking all sorted questions...")
        var displayedAny = false

        for question in questions {
            if shouldAskQuestionAgain(for: question) {
                print("🆗 Displaying question: \(question.text)")
                displayQuestion(question)
                displayedAny = true
                break // Ask one question at a time
            }
        }

        if !displayedAny {
            print("⚠️ No questions to display!")
        }
    }

    
    // MARK: - Sort Questions
    private func sortQuestions() {
        print("📌 Sorting questions before asking.")

        self.questions.sort { (q1, q2) -> Bool in
            if !q1.isAnswered && q2.isAnswered { return true }
            if q1.isAnswered && !q2.isAnswered { return false }
            return q1.priority < q2.priority
        }

        for question in self.questions {
            print("➡️ Question in sorted order: \(question.text), isAnswered: \(question.isAnswered)")
        }
    }


//    private func moveToNextQuestion() {
//        // Assuming `questions` is a list of all fetched questions
//        guard !questions.isEmpty else { return }
//
//        // Logic to find the next question that needs to be asked
//        // For example, you might have a flag `isAnswered` or `askInterval` to determine which question to show
//        if let nextQuestion = questions.first(where: { !$0.isAnswered }) {
//            displayQuestion(nextQuestion)
//        } else {
//            print("No unanswered questions available.")
//        }
//    }



    private func shouldAskQuestionAgain(for question: Question) -> Bool {
        if !question.isAnswered {
            return true // Question hasn't been answered yet, ask it
        }
        
        // Check if the current time is greater than the next ask time
        if let lastAsked = question.lastAsked {
            let nextAskTime = lastAsked.addingTimeInterval(TimeInterval(question.askInterval))
            if Date() >= nextAskTime {
                return true // Time to ask again
            }
        }
        
        return false
    }



    // MARK: - Generate Random Questions (for testing)
    private func generateRandomQuestions() -> [Question] {
        var randomQuestions: [Question] = []

        // Generate 5 random questions for testing
        for i in 1...5 {
            let question = Question(
                text: "Sample Question #\(i)",
                category: .immediateMemory,
                subcategory: .general,
                tag: nil,
                answerOptions: ["Option A", "Option B", "Option C", "Option D"],
                answers: [],
                correctAnswers: ["Option A"],
                image: nil,
                isAnswered: false,
                askInterval: 0,
                timeFrame: TimeFrame(from: "00:00", to: "00:00"),
                priority: 1,
                audio: nil,
                isActive: true,
                hint: nil,
                confidence: nil,
                hardness: 1,
                questionType: .multipleChoice
            )
            randomQuestions.append(question)
        }
        
        return randomQuestions
    }


    // MARK: - Display Current Question
    private func displayCurrentQuestion() {
        guard currentQuestionIndex < questions.count else {
            print("No more questions")
            return
        }
        
        let currentQuestion = questions[currentQuestionIndex]
        
        if shouldAskQuestionAgain(for: currentQuestion) {
            questionLabel.text = currentQuestion.text
            
            // Set image if available
            if let imageString = currentQuestion.image, let imageData = Data(base64Encoded: imageString) {
                questionImageView.image = UIImage(data: imageData)
            }

            // Clear previous options
            optionsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

            let options = currentQuestion.answerOptions
            let isOdd = options.count % 2 != 0
            let lastIndex = options.count - 1
            
            var currentRowStack: UIStackView?

            for index in 0..<options.count {
                if index % 2 == 0 {
                    // Create a new horizontal stack for every two buttons
                    currentRowStack = UIStackView()
                    currentRowStack?.axis = .horizontal
                    currentRowStack?.spacing = 16
                    currentRowStack?.distribution = .fillEqually
                    currentRowStack?.translatesAutoresizingMaskIntoConstraints = false
                    optionsContainer.addArrangedSubview(currentRowStack!)
                }
                
                let button = createOptionButton(with: options[index])
                button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)

                // If it's the last element and count is odd, make it a full-width button
                if isOdd && index == lastIndex {
                    let fullWidthStack = UIStackView()
                    fullWidthStack.axis = .horizontal
                    fullWidthStack.spacing = 16
                    fullWidthStack.distribution = .fill
                    fullWidthStack.translatesAutoresizingMaskIntoConstraints = false
                    optionsContainer.addArrangedSubview(fullWidthStack)

                    fullWidthStack.addArrangedSubview(button)
                } else {
                    currentRowStack?.addArrangedSubview(button)
                }
            }
        } else {
            moveToNextQuestion() // Skip if not time to ask
        }
    }



    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(questionLabel)
        view.addSubview(questionImageView)
        view.addSubview(optionsContainer)
        view.addSubview(submitButton)
        view.addSubview(footerLabel)

        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            questionImageView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 10),
            questionImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            questionImageView.widthAnchor.constraint(equalToConstant: 150),
            questionImageView.heightAnchor.constraint(equalToConstant: 150),

            optionsContainer.topAnchor.constraint(equalTo: questionImageView.bottomAnchor, constant: 5),
            optionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
                    submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    submitButton.widthAnchor.constraint(equalToConstant: 120),
                    submitButton.heightAnchor.constraint(equalToConstant: 50),

                    footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
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
        selectedOptionButton?.layer.borderColor = UIColor.lightGray.cgColor
        selectedOptionButton?.backgroundColor = .white
        
        selectedOptionButton = sender
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
    }

    // MARK: - Submit Button Action
    @objc private func submitButtonTapped() {
        guard let selectedAnswer = selectedOptionButton?.title(for: .normal) else { return }

        // Mark question as answered
        var currentQuestion = questions[currentQuestionIndex]
        currentQuestion.isAnswered = true
        currentQuestion.answers.append(selectedAnswer)
        
        // Update Firestore with the answer
        let questionRef = db.collection("users").document(verifiedUserDocID).collection("questions").document(currentQuestion.id!)
        questionRef.updateData([
            "isAnswered": true,
            "answers": currentQuestion.answers // Allow multiple answers here
        ]) { [weak self] error in
            if let error = error {
                print("Error updating question: \(error.localizedDescription)")
            } else {
                self?.showNextQuestionConfirmation() // Go to the next available question after submitting the answer
            }
        }
        let streakService = StreakService(verifiedUserDocID: verifiedUserDocID)
           
        
        // Update streak for today
        streakService.updateStreakForToday(with: true)

        // Update 'lastAnswered' in the user's core analytics subcollection
        let analyticsRef = db.collection("users").document(verifiedUserDocID).collection("core").document("analytics")
        analyticsRef.updateData([
            "lastAnswered": Date() // This will store the current timestamp for when the last answer was submitted
        ]) { error in
            if let error = error {
                print("Error updating lastAnswered: \(error.localizedDescription)")
            } else {
                print("lastAnswered successfully updated")
            }
        }
        
        let streaksCoresRef = db.collection("users").document(verifiedUserDocID).collection("streaksCore").document("streakData")

        streaksCoresRef.getDocument { document, error in
            if let error = error {
                print("Error fetching streak data: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                let maxStreak = data?["maxStreak"] as? Int ?? 0
                let currentStreak = data?["currentStreak"] as? Int ?? 0
                let lastAnsweredTimestamp = data?["lastAnswered"] as? Timestamp
                let lastAnsweredDate = lastAnsweredTimestamp?.dateValue()
                
                let today = Calendar.current.startOfDay(for: Date())
                let lastAnsweredDay = lastAnsweredDate.map { Calendar.current.startOfDay(for: $0) }
                
                // If lastAnswered date is already today, do not update
                if lastAnsweredDay == today {
                    print("✅ Streak already updated today. Skipping update.")
                    return
                }
                
                let updatedMaxStreak = max(currentStreak + 1, maxStreak) // Ensure maxStreak is correctly updated
                
                // Update the streak data
                streaksCoresRef.updateData([
                    "activeDays": FieldValue.increment(Int64(1)),
                    "currentStreak": FieldValue.increment(Int64(1)),
                    "maxStreak": updatedMaxStreak,
                    "lastAnswered": Timestamp(date: Date())
                ]) { error in
                    if let error = error {
                        print("Error updating streak data: \(error.localizedDescription)")
                    } else {
                        print("🔥 Streak data successfully updated!")
                    }
                }
            }
        }

    }

    private func submitAnswer(_ answer: String) {
        var currentQuestion = questions[currentQuestionIndex]
        
        guard let questionID = currentQuestion.id else {
            print("❌ Error: Question ID is missing.")
            return
        }

        // Mark as answered and add the answer
        currentQuestion.isAnswered = true
        currentQuestion.answers.append(answer)

        // Update Firestore document
        let questionRef = db.collection("users").document(verifiedUserDocID).collection("questions").document(questionID)
        questionRef.updateData([
            "isAnswered": true,
            "answers": currentQuestion.answers,
            "lastAsked": Date()
        ]) { [weak self] error in
            if let error = error {
                print("❌ Error updating question: \(error.localizedDescription)")
            } else {
                self?.showNextQuestionConfirmation()
            }
        }
    }


    
    private func showNextQuestionConfirmation() {
        let alertController = UIAlertController(
            title: "Question Submitted",
            message: "Do you want to go to the next question or exit?",
            preferredStyle: .alert
        )
        
        // "Next Question" action
        let nextQuestionAction = UIAlertAction(title: "Next Question", style: .default) { [weak self] _ in
            self?.moveToNextQuestion()
        }
        
        // "Exit" action
        let exitAction = UIAlertAction(title: "Exit", style: .cancel) { [weak self] _ in
            self?.exitQuestionFlow()
        }
        
        // Add actions to alert
        alertController.addAction(nextQuestionAction)
        alertController.addAction(exitAction)
        
        // Present the alert
        present(alertController, animated: true, completion: nil)
    }




    // MARK: - Move to Next Question
    private func moveToNextQuestion() {
        currentQuestionIndex += 1
        while currentQuestionIndex < questions.count {
            let nextQuestion = questions[currentQuestionIndex]
            if shouldAskQuestionAgain(for: nextQuestion) {
                displayQuestion(nextQuestion)
                return
            }
            currentQuestionIndex += 1
        }

        print("🚫 No more questions available.")
        exitQuestionFlow()
    }


    private func displayQuestion(_ question: Question) {
        questionLabel.text = question.text

        // Set image if available
        if let imageString = question.image, let imageData = Data(base64Encoded: imageString) {
            questionImageView.image = UIImage(data: imageData)
        }

        // Clear previous options
        optionsContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let options = question.answerOptions
        let isOdd = options.count % 2 != 0
        let lastIndex = options.count - 1

        var currentRowStack: UIStackView?

        for index in 0..<options.count {
            if index % 2 == 0 {
                // Create a new horizontal stack for every two buttons
                currentRowStack = UIStackView()
                currentRowStack?.axis = .horizontal
                currentRowStack?.spacing = 16
                currentRowStack?.distribution = .fillEqually
                currentRowStack?.translatesAutoresizingMaskIntoConstraints = false
                optionsContainer.addArrangedSubview(currentRowStack!)
            }

            let button = createOptionButton(with: options[index])
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)

            // If it's the last button and count is odd, make it full width
            if isOdd && index == lastIndex {
                let fullWidthStack = UIStackView()
                fullWidthStack.axis = .horizontal
                fullWidthStack.spacing = 16
                fullWidthStack.distribution = .fill
                fullWidthStack.translatesAutoresizingMaskIntoConstraints = false
                optionsContainer.addArrangedSubview(fullWidthStack)

                fullWidthStack.addArrangedSubview(button)
            } else {
                currentRowStack?.addArrangedSubview(button)
            }
        }

        // Update question as being asked
        updateQuestionLastAsked(question)
    }

    private func updateQuestionLastAsked(_ question: Question) {
        let questionRef = db.collection("users").document(verifiedUserDocID).collection("questions").document(question.id!)
        questionRef.updateData([
            "lastAsked": Date()
        ])
    }

    
    private func showNoQuestionsReadyAlert() {
        let alertController = UIAlertController(
            title: "No Questions Ready",
            message: "All questions are either answered or not due for asking yet.",
            preferredStyle: .alert
        )
        
        let exitAction = UIAlertAction(title: "Exit", style: .cancel) { [weak self] _ in
            self?.exitQuestionFlow()
        }
        
        alertController.addAction(exitAction)
        present(alertController, animated: true, completion: nil)
    }



    // MARK: - Exit the Question Flow
    private func exitQuestionFlow() {
        // Optionally, you can handle any exit logic (e.g., navigate to another screen or stop the process)
        print("Exiting question flow.")
        // For example, pop the current view controller if you're using a navigation controller
        navigationController?.popViewController(animated: true)
    }

}
//#Preview {
//    PatientQuestionsViewController()
//}
