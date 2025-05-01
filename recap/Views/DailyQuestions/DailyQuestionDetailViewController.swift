//
//  DailyQuestionDetailViewController.swift
//  Recap
//
//  Created by s1834 on 15/01/25.
//

//
//import UIKit
//import FirebaseFirestore
//
//class DailyQuestionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionDetailDelegate {
//    var verifiedUserDocID: String
//    private var manager: QuestionsManager
//    private var questions: [Question] = []
//    private var lastFetchTime: Date?
//    private let fetchInterval: TimeInterval = 86400.0
//    
//    private let tableView: UITableView = {
//        let table = UITableView()
//        table.translatesAutoresizingMaskIntoConstraints = false
//        table.separatorStyle = .none
//        table.rowHeight = UITableView.automaticDimension
//        table.estimatedRowHeight = 120
//        return table
//    }()
//
//    init(verifiedUserDocID: String) {
//        self.verifiedUserDocID = verifiedUserDocID
//        self.manager = QuestionsManager(verifiedUserDocID: verifiedUserDocID)
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    var fetchTimer: Timer?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadQuestions()
//        startFetchingQuestions()
//    }
//
//    private func setupUI() {
//        view.backgroundColor = .white
//        title = "Daily Question"
//            
//        navigationItem.rightBarButtonItem = UIBarButtonItem(
//            barButtonSystemItem: .add,
//            target: self,
//            action: #selector(addQuestion)
//        )
//        
//        let captionLabel = UILabel()
//        captionLabel.text = "Answer your loved one's daily questions anytime to support their memory journey."
//        captionLabel.font = UIFont.systemFont(ofSize: 18)
//        captionLabel.textColor = .gray
//        captionLabel.numberOfLines = 0
//        captionLabel.translatesAutoresizingMaskIntoConstraints = false
//            
//        view.addSubview(captionLabel)
//        view.addSubview(tableView)
//            
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
//            
//        NSLayoutConstraint.activate([
//            captionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            captionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//                
//            tableView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 16),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    func startFetchingQuestions() {
//        if fetchTimer == nil {
//            fetchTimer = Timer.scheduledTimer(timeInterval: fetchInterval, target: self, selector: #selector(fetchNewQuestions), userInfo: nil, repeats: true)
//            RunLoop.main.add(fetchTimer!, forMode: .common)
//        }
//    }
//
//    @objc private func fetchNewQuestions() {
//        self.manager.fetchQuestions { [weak self] (fetchedQuestions: [Question]) in
//            guard let self = self else { return }
//
//            self.questions = fetchedQuestions
//            self.lastFetchTime = Date()
//            let db = Firestore.firestore()
//            let coreRef = db.collection("users").document(self.verifiedUserDocID).collection("core").document("analytics")
//
//            coreRef.updateData([
//                "lastFetched": self.lastFetchTime ?? Date()
//            ]) { error in
//                if let error = error {
//                    print("❌❌ Error updating lastFetched timestamp: \(error.localizedDescription)")
//                }
//            }
//            self.tableView.reloadData()
//        }
//    }
//
//    @objc func loadQuestions() {
//        let currentTime = Date()
//
//        if let lastFetch = lastFetchTime, currentTime.timeIntervalSince(lastFetch) < fetchInterval {
//            tableView.reloadData()
//            return
//        }
//
//        evaluateAndStoreMemoryReport(for: verifiedUserDocID) { [weak self] in
//            guard let self = self else { return }
//
//            // Move questions to asked before fetching new ones
//            self.manager.moveQuestionsToAskedAndDelete {
//                let db = Firestore.firestore()
//                let userQuestionsRef = db.collection("users").document(self.verifiedUserDocID).collection("questions")
//
//                userQuestionsRef.getDocuments { (snapshot, error) in
//                    if let error = error {
//                        print("❌ Firestore error while checking questions collection: \(error.localizedDescription)")
//                        return
//                    }
//
//                    if let snapshot = snapshot, !snapshot.isEmpty {
//                        let filteredQuestions = snapshot.documents.compactMap { doc -> Question? in
//                            do {
//                                var question = try doc.data(as: Question.self)
//                                return question.correctAnswers?.isEmpty ?? true ? question : nil
//                            } catch {
//                                print("❌ Error decoding question: \(error)")
//                                return nil
//                            }
//                        }
//
//                        if !filteredQuestions.isEmpty {
//                            self.questions.append(contentsOf: filteredQuestions)
//                            self.tableView.reloadData()
//                        } else {
//                            self.fetchRandomQuestions(from: userQuestionsRef)
//                        }
//                    } else {
//                        self.fetchNewQuestions()
//                    }
//                }
//            }
//        }
//    }
//
//
//    private func fetchRandomQuestions(from collectionRef: CollectionReference) {
//        collectionRef.limit(to: 7).getDocuments { [weak self] (snapshot, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("❌❌ Firestore error while fetching random questions: \(error.localizedDescription)")
//                return
//            }
//
//            if let snapshot = snapshot {
//                let randomQuestions = snapshot.documents.compactMap { doc in
//                    do {
//                        let question = try doc.data(as: Question.self)
//                        return question
//                    } catch {
//                        print("❌❌ Error decoding random question: \(error)")
//                        return nil
//                    }
//                }
//                self.questions.append(contentsOf: randomQuestions)
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return questions.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionCell.identifier, for: indexPath) as? QuestionCell else {
//            return UITableViewCell()
//        }
//        
//        let question = questions[indexPath.row]
//        cell.configure(with: question)
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let selectedQuestion = questions[indexPath.row]
//        let questionDetailVC = QuestionDetailViewController(verifiedUserDocID: verifiedUserDocID)
//        questionDetailVC.question = selectedQuestion
//        questionDetailVC.delegate = self
//        navigationController?.pushViewController(questionDetailVC, animated: true)
//    }
//    
//    @objc private func addQuestion() {
//        let addQuestionVC = AddQuestionViewController(verifiedUserDocID: self.verifiedUserDocID)
//        let navController = UINavigationController(rootViewController: addQuestionVC)
//        
//        if let sheet = navController.sheetPresentationController {
//            if #available(iOS 16.0, *) {
//                sheet.detents = [.large()]
//            } else {
//                sheet.detents = [.medium()]
//            }
//            sheet.prefersGrabberVisible = true
//            sheet.prefersEdgeAttachedInCompactHeight = true
//        }
//        present(navController, animated: true, completion: nil)
//    }
//    
//    func didSubmitAnswer(for question: Question) {
//        if let index = questions.firstIndex(where: { $0.id == question.id }) {
//            var answeredQuestion = questions.remove(at: index)
//            answeredQuestion.isAnswered = true
//            questions.append(answeredQuestion)
//            tableView.reloadData()
//        }
//    }
//}
//
//  DailyQuestionDetailViewController.swift
//  Recap
//
//  Created by s1834 on 15/01/25.
//


import UIKit
import FirebaseFirestore

class DailyQuestionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, QuestionDetailDelegate {
    var verifiedUserDocID: String
    private var manager: QuestionsManager
    private var questions: [Question] = []
    private var lastFetchTime: Date?
    private let fetchInterval: TimeInterval = 86400.0
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        return table
    }()

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        self.manager = QuestionsManager(verifiedUserDocID: verifiedUserDocID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var fetchTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestions()
        startFetchingQuestions()
    }

    private func setupUI() {
        view.backgroundColor = .white
        title = "Daily Question"
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addQuestion)
        )
        
        let captionLabel = UILabel()
        captionLabel.text = "Answer your loved one's daily questions anytime to support their memory journey."
        captionLabel.font = UIFont.systemFont(ofSize: 18)
        captionLabel.textColor = .gray
        captionLabel.numberOfLines = 0
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
            
        view.addSubview(captionLabel)
        view.addSubview(tableView)
            
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(QuestionCell.self, forCellReuseIdentifier: QuestionCell.identifier)
            
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
    
    func startFetchingQuestions() {
        if fetchTimer == nil {
            fetchTimer = Timer.scheduledTimer(timeInterval: fetchInterval, target: self, selector: #selector(fetchNewQuestions), userInfo: nil, repeats: true)
            RunLoop.main.add(fetchTimer!, forMode: .common)
        }
    }

    @objc private func fetchNewQuestions() {
        self.manager.fetchQuestions { [weak self] (fetchedQuestions: [Question]) in
            guard let self = self else { return }

            self.questions = fetchedQuestions
            self.lastFetchTime = Date()
            let db = Firestore.firestore()
            let coreRef = db.collection("users").document(self.verifiedUserDocID).collection("core").document("analytics")

            coreRef.updateData([
                "lastFetched": self.lastFetchTime ?? Date()
            ]) { error in
                if let error = error {
                    print("❌❌ Error updating lastFetched timestamp: \(error.localizedDescription)")
                }
            }
            self.tableView.reloadData()
        }
    }

    @objc func loadQuestions() {
        let currentTime = Date()

        if let lastFetch = lastFetchTime, currentTime.timeIntervalSince(lastFetch) < fetchInterval {
            tableView.reloadData()
            return
        }

        evaluateAndStoreMemoryReport(for: verifiedUserDocID) { [weak self] in
            guard let self = self else { return }

            // Move questions to asked before fetching new ones
            self.manager.moveQuestionsToAskedAndDelete {
                let db = Firestore.firestore()
                let userQuestionsRef = db.collection("users").document(self.verifiedUserDocID).collection("questions")

                userQuestionsRef.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("❌ Firestore error while checking questions collection: \(error.localizedDescription)")
                        return
                    }

                    if let snapshot = snapshot, !snapshot.isEmpty {
                        let filteredQuestions = snapshot.documents.compactMap { doc -> Question? in
                            do {
                                var question = try doc.data(as: Question.self)
                                return question.correctAnswers?.isEmpty ?? true ? question : nil
                            } catch {
                                print("❌ Error decoding question: \(error)")
                                return nil
                            }
                        }

                        if !filteredQuestions.isEmpty {
                            self.questions.append(contentsOf: filteredQuestions)
                            self.tableView.reloadData()
                        } else {
                            self.fetchRandomQuestions(from: userQuestionsRef)
                        }
                    } else {
                        self.fetchNewQuestions()
                    }
                }
            }
        }
    }


    private func fetchRandomQuestions(from collectionRef: CollectionReference) {
        collectionRef.limit(to: 7).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("❌❌ Firestore error while fetching random questions: \(error.localizedDescription)")
                return
            }

            if let snapshot = snapshot {
                let randomQuestions = snapshot.documents.compactMap { doc in
                    do {
                        let question = try doc.data(as: Question.self)
                        return question
                    } catch {
                        print("❌❌ Error decoding random question: \(error)")
                        return nil
                    }
                }
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
    
    func didSubmitAnswer(for question: Question) {
        if let index = questions.firstIndex(where: { $0.id == question.id }) {
            var answeredQuestion = questions.remove(at: index)
            answeredQuestion.isAnswered = true
            questions.append(answeredQuestion)
            tableView.reloadData()
        }
    }
}
#Preview{
    DailyQuestionDetailViewController(verifiedUserDocID: "E4McfMAfgATYMSvzx43wm7r1WQ23")
}
