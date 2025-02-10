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
    private func startFetchingQuestions() {
        fetchTimer = Timer.scheduledTimer(timeInterval: 86400.0, target: self, selector: #selector(loadQuestions), userInfo: nil, repeats: true)
        loadQuestions()  // Fetch questions initially
    }
    // MARK: - Load Questions from Firestore
    @objc func loadQuestions() {
        manager.fetchQuestions { [weak self] (fetchedQuestions: [Question]) in
            self?.questions = fetchedQuestions
            self?.tableView.reloadData()
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
