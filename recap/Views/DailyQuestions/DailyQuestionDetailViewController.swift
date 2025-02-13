//
//  DailyQuestionDetailViewController.swift
//  Recap
//
//  Created by user@47 on 15/01/25.
//


import UIKit
import FirebaseFirestore

class DailyQuestionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionDetailDelegate {
    var question: Question?
    var verifiedUserDocID: String
    private var manager: QuestionsManager
    private var questions: [Question] = []
    private var lastFetchTime: Date?
    private let fetchInterval: TimeInterval = 86400.0

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        self.manager = QuestionsManager(verifiedUserDocID: verifiedUserDocID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Answer your loved one's daily questions anytime to support their memory journey."
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }()
    
    // Timer property
    var fetchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Daily Question"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addQuestion)
        )
        view.addSubview(captionLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
        
        setupConstraints()
        
        // Display cached questions if available, else fetch
        loadQuestions()
        
        // Start the 24-hour refresh timer
        startFetchingQuestions()
    }



    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            captionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Start Timer to Fetch Questions Every 24 Hours
    func startFetchingQuestions() {
        if fetchTimer == nil { // Ensure only one timer runs
            // Schedule the timer to call fetchNewQuestions instead of loadQuestions
            fetchTimer = Timer.scheduledTimer(timeInterval: fetchInterval, target: self, selector: #selector(fetchNewQuestions), userInfo: nil, repeats: true)
            // Add timer to run on the main run loop, to ensure it gets triggered properly
            RunLoop.main.add(fetchTimer!, forMode: .common)
        }
    }

    // Fetch New Questions (Always fetch fresh questions, regardless of existing data)
    @objc private func fetchNewQuestions() {
        self.manager.fetchQuestions { [weak self] (fetchedQuestions: [Question]) in
            guard let self = self else { return }

            self.questions = fetchedQuestions
            self.lastFetchTime = Date() // Update fetch timestamp
            
            // Update the last fetched timestamp in Firestore
            let db = Firestore.firestore()
            let coreRef = db.collection("users")
                              .document(self.verifiedUserDocID)
                              .collection("core")
                              .document("analytics")

            coreRef.updateData([
                "lastFetched": self.lastFetchTime ?? Date()
            ]) { error in
                if let error = error {
                    print("❌ Error updating lastFetched timestamp: \(error.localizedDescription)")
                } else {
                    print("✅ lastFetched timestamp updated successfully.")
                }
            }

            self.tableView.reloadData() // Ensure the table view is reloaded
            print("✅ Questions successfully loaded.")
        }
    }


    // Load Questions from Firestore (No longer used in the timer selector)
    @objc func loadQuestions() {
        let currentTime = Date()

        // Only proceed if it's been more than the set interval (20 seconds) since the last fetch
        if let lastFetch = lastFetchTime, currentTime.timeIntervalSince(lastFetch) < fetchInterval {
            print("✅ It's within \(Int(fetchInterval)) seconds. Skipping fetch.")
            tableView.reloadData()
            return
        }

        print("🔄 Fetching questions...")

        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")

        // Skip collection check and directly fetch new questions on timer-based fetch
        userQuestionsRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("❌ Firestore error while checking questions collection: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot, !snapshot.isEmpty {
                print("📌 Found existing questions in Firestore.")
                
                // Filter questions where correctAnswers is empty
                let filteredQuestions = snapshot.documents.compactMap { doc in
                    do {
                        var question = try doc.data(as: Question.self)
                        
                        // Check if the question has an empty correctAnswers field
                        if question.correctAnswers?.isEmpty ?? true {
                            return question
                        } else {
                            return nil // Ignore questions where correctAnswers is not empty
                        }
                    } catch {
                        print("❌ Error decoding question: \(error)")
                        return nil
                    }
                }

                if !filteredQuestions.isEmpty {
                    // If questions are found with empty correctAnswers, add to questions array
                    self.questions.append(contentsOf: filteredQuestions)
                    self.tableView.reloadData()
                } else {
                    // If no questions with empty correctAnswers, fetch 7 random questions
                    print("⚠️ No questions with empty correctAnswers. Fetching 7 random questions.")
                    self.fetchRandomQuestions(from: userQuestionsRef)
                }
            } else {
                // If collection is empty or no valid questions are found, fetch fresh questions from the server
                print("⚠️ No questions found in Firestore. Fetching new questions...")
                self.fetchNewQuestions()
            }
        }
    }

    // Fetch 7 Random Questions
    private func fetchRandomQuestions(from collectionRef: CollectionReference) {
        // Fetch 7 random questions from Firestore
        collectionRef.limit(to: 7).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("❌ Firestore error while fetching random questions: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                print("📌 Found \(snapshot.documents.count) random questions in Firestore.")

                // Map the documents to Question objects
                let randomQuestions = snapshot.documents.compactMap { doc in
                    do {
                        let question = try doc.data(as: Question.self)
                        return question
                    } catch {
                        print("❌ Error decoding random question: \(error)")
                        return nil
                    }
                }

                // Append the fetched random questions to the existing ones
                self.questions.append(contentsOf: randomQuestions)
                self.tableView.reloadData()
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionCell.identifier, for: indexPath) as? QuestionCell else {
            return UITableViewCell()
        }
        
        let question = questions[indexPath.row]
        cell.configure(with: question)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedQuestion = questions[indexPath.row]
        let questionDetailVC = QuestionDetailViewController(verifiedUserDocID: verifiedUserDocID)
        questionDetailVC.question = selectedQuestion
        questionDetailVC.delegate = self 
        navigationController?.pushViewController(questionDetailVC, animated: true)
    }
    
    @objc private func addQuestion() {
        let addQuestionVC = AddQuestionViewController(verifiedUserDocID: self.verifiedUserDocID)
        let navController = UINavigationController(rootViewController: addQuestionVC)
        
        if let sheet = navController.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.large()]
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Delegate Method to Handle Answer Submission
    func didSubmitAnswer(for question: Question) {
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            var answeredQuestion = questions.remove(at: index)
            answeredQuestion.isAnswered = true
            questions.append(answeredQuestion)
            tableView.reloadData()
        }
    }
}

#Preview {
    DailyQuestionDetailViewController(verifiedUserDocID: "DT7GZI")
}
