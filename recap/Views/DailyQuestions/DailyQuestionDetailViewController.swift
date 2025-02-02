import UIKit
import FirebaseFirestore

class DailyQuestionDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var question: Question?
    
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
    
    var questions: [Question] = []

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
        startFetchingQuestions()  // Start fetching questions every 20 seconds
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

    // MARK: - Start Timer to Fetch Questions Every 20 Seconds
    private func startFetchingQuestions() {
        fetchTimer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(loadQuestions), userInfo: nil, repeats: true)
        
        // Also fetch questions initially
        loadQuestions()
    }

    // MARK: - Load Questions from Firestore
    @objc func loadQuestions() {
        // Clear the existing questions before adding new ones
        self.questions.removeAll()
        self.tableView.reloadData()

        let db = Firestore.firestore()

        // Create references to the 'Questions' collection
        let questionsRef = db.collection("Questions")
        
        // Fetch questions from different categories
        let immediateMemoryRef = questionsRef.whereField("category", isEqualTo: "immediateMemory").limit(to: 7)
        let recentMemoryRef = questionsRef.whereField("category", isEqualTo: "recentMemory").limit(to: 5)
        let remoteMemoryRef = questionsRef.whereField("category", isEqualTo: "remoteMemory").limit(to: 2)
        
        // Fetch the questions in parallel
        let group = DispatchGroup()
        
        var immediateMemoryQuestions: [Question] = []
        var recentMemoryQuestions: [Question] = []
        var remoteMemoryQuestions: [Question] = []
        
        group.enter()
        immediateMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching immediate memory questions: \(error.localizedDescription)")
            } else {
                immediateMemoryQuestions = snapshot?.documents.compactMap { doc in
                    return self.convertToQuestion(doc: doc)
                } ?? []
            }
            group.leave()
        }
        
        group.enter()
        recentMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recent memory questions: \(error.localizedDescription)")
            } else {
                recentMemoryQuestions = snapshot?.documents.compactMap { doc in
                    return self.convertToQuestion(doc: doc)
                } ?? []
            }
            group.leave()
        }
        
        group.enter()
        remoteMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching remote memory questions: \(error.localizedDescription)")
            } else {
                remoteMemoryQuestions = snapshot?.documents.compactMap { doc in
                    return self.convertToQuestion(doc: doc)
                } ?? []
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            // Combine all the questions
            let allQuestions = immediateMemoryQuestions + recentMemoryQuestions + remoteMemoryQuestions
            self.questions = allQuestions
            self.tableView.reloadData()

            // Push questions to Firestore
            self.pushQuestionsToFirestore(allQuestions)
        }
    }

    // MARK: - Convert Firestore Document to Question Model
    private func convertToQuestion(doc: QueryDocumentSnapshot) -> Question? {
        var data = doc.data()

        guard let categoryString = data["category"] as? String,
              let category = QuestionCategory(rawValue: categoryString) else {
            print("Invalid category type or value for document \(doc.documentID)")
            return nil
        }

        guard let text = data["text"] as? String else {
            print("Missing text for document \(doc.documentID)")
            return nil
        }

        let subcategory = data["subcategory"] as? String ?? ""
        let answerOptions = data["answerOptions"] as? [String] ?? []
        let isAnswered = data["isAnswered"] as? Bool ?? false
        let askInterval = data["askInterval"] as? Int ?? 0
        let timesAsked = data["timesAsked"] as? Int ?? 0
        let timesAnsweredCorrectly = data["timesAnsweredCorrectly"] as? Int ?? 0
        let tag = data["tag"] as? String ?? ""
        let image = data["image"] as? String
        let lastAskedString = data["lastAsked"] as? String

        // Convert string to Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"  // Adjust format to match your Firestore format
        let lastAsked = dateFormatter.date(from: lastAskedString ?? "")

        let timeInterval: TimeInterval = TimeInterval(askInterval)

        return Question(
            id: doc.documentID,
            text: text,
            category: category,
            subcategory: QuestionSubcategory(rawValue: subcategory) ?? .general,
            tag: tag,  // tag comes before answerOptions
            answerOptions: answerOptions,
            image: image,  // image comes before isAnswered
            isAnswered: isAnswered,
            askInterval: timeInterval,
            lastAsked: lastAsked,  // lastAsked comes before timesAsked
            timesAsked: timesAsked,
            timesAnsweredCorrectly: timesAnsweredCorrectly
        )
    }

    // MARK: - Push Selected Questions to Firestore
    private func pushQuestionsToFirestore(_ questions: [Question]) {
        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document("9CeE16ZpiraefexnqTop8NF5O8n2").collection("questions")

        for question in questions {
            guard let questionID = question.id else {
                print("Skipping upload due to missing question ID")
                continue
            }

            userQuestionsRef.document(questionID).setData([
                "id": questionID,
                "text": question.text,
                "category": question.category.rawValue,
                "answerOptions": question.answerOptions,
                "askInterval": question.askInterval,
                "isAnswered": question.isAnswered,
                "lastAsked": question.lastAsked ?? NSNull(),
                "subcategory": question.subcategory.rawValue,
                "tag": question.tag,
                "image": question.image ?? NSNull(),
                "timesAnsweredCorrectly": question.timesAnsweredCorrectly,
                "timesAsked": question.timesAsked
            ]) { error in
                if let error = error {
                    print("Error uploading question \(questionID): \(error.localizedDescription)")
                } else {
                    print("Successfully uploaded question \(questionID)")
                }
            }
        }
    }
    

    @objc private func addQuestion() {
        let addQuestionVC = AddQuestionViewController()
        let navController = UINavigationController(rootViewController: addQuestionVC)

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }

        present(navController, animated: true, completion: nil)
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
        cell.contentView.preservesSuperviewLayoutMargins = false
        cell.preservesSuperviewLayoutMargins = false

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedQuestion = questions[indexPath.row]
        let detailVC = QuestionDetailViewController()
        detailVC.question = selectedQuestion
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
