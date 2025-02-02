import UIKit
import FirebaseFirestore

enum QuestionCategory: String, Codable {
    case immediateMemory
    case recentMemory
    case remoteMemory
}

enum QuestionSubcategory: String, Codable {
    case dailyRoutine
    case general
    case health
    case family
    case spiritual
    case hobbies
    case musicMovies
}

struct Question: Identifiable, Codable {
    @DocumentID var id: String? // Firebase Document ID
    var text: String
    var category: QuestionCategory
    var subcategory: QuestionSubcategory
    var tag: String? // e.g., "Medication", "Eating", etc.
    var answerOptions: [String]
    var image: String? // Store image URL instead of data for easier storage
    var isAnswered: Bool
    var askInterval: TimeInterval // in seconds
    var lastAsked: Date? // Tracks the last time the question was asked
    var timesAsked: Int // Tracks how many times the question was asked
    var timesAnsweredCorrectly: Int // Tracks how many times the question was answered correctly
}

extension Question {
    // Custom initializer to use when adding questions to Firestore
    init(text: String, category: QuestionCategory, subcategory: QuestionSubcategory, tag: String?, answerOptions: [String], image: String?, isAnswered: Bool, askInterval: TimeInterval) {
        self.text = text
        self.category = category
        self.subcategory = subcategory
        self.tag = tag
        self.answerOptions = answerOptions
        self.image = image
        self.isAnswered = isAnswered
        self.askInterval = askInterval
        self.lastAsked = nil // If this is a new question, the lastAsked date is nil
        self.timesAsked = 0
        self.timesAnsweredCorrectly = 0
    }
}

class DailyQuestionsViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the activity indicator
        setupActivityIndicator()

        // Call the function to add questions to Firestore
        addQuestionsToFirestore()
    }

    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        view.addSubview(activityIndicator!)
        activityIndicator?.startAnimating()
    }

    func addQuestionsToFirestore() {
        let db = Firestore.firestore()

        let questions: [Question] = [
            Question(
                text: "Did you take your morning medication today?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Medication",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "What did you eat for breakfast this morning?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Eating",
                answerOptions: ["Cereal", "Toast", "Fruit", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "Did you brush your teeth after waking up today?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Self-care",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "Did you have your afternoon snacks today?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Eating",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "Have you changed into your nightwear?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Self-care",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "What time did you wake up today?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Sleep/Wake",
                answerOptions: ["Before 7 AM", "7-8 AM", "After 8 AM", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "Did you listen to music this afternoon?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Music",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            ),
            Question(
                text: "Did you take your afternoon medication?",
                category: .immediateMemory,
                subcategory: .dailyRoutine,
                tag: "Medication",
                answerOptions: ["Yes", "No", "Not Sure"],
                image: nil,
                isAnswered: false,
                askInterval: 86400
            )
        ]

        // Add the questions to Firestore
        for question in questions {
            var questionData: [String: Any] = [
                "text": question.text,
                "category": question.category.rawValue,
                "subcategory": question.subcategory.rawValue,
                "tag": question.tag ?? NSNull(),
                "answerOptions": question.answerOptions,
                "image": question.image ?? NSNull(),
                "isAnswered": question.isAnswered,
                "askInterval": question.askInterval,
                "lastAsked": question.lastAsked ?? NSNull(),
                "timesAsked": question.timesAsked,
                "timesAnsweredCorrectly": question.timesAnsweredCorrectly
            ]
            
            // Add the document to Firestore
            db.collection("Questions").addDocument(data: questionData) { error in
                if let error = error {
                    print("Error adding question: \(error.localizedDescription)")
                } else {
                    print("Question successfully added to Firestore.")
                }
            }
        }

        // Stop the activity indicator after the data is sent
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
        }
    }
}

func shouldAskQuestion(question: Question, currentDate: Date) -> Bool {
    guard let lastAsked = question.lastAsked else {
        return true // If the question has never been asked, it should be asked
    }
    return currentDate.timeIntervalSince(lastAsked) >= question.askInterval
}

func updateAskInterval(for question: inout Question, wasAnsweredCorrectly: Bool) {
    if wasAnsweredCorrectly {
        question.askInterval *= 1.5 // Increase the interval by 50% for correct answers
        question.timesAnsweredCorrectly += 1
    } else {
        question.askInterval = max(3600, question.askInterval / 2) // Decrease interval but ensure a minimum of 1 hour
    }
    question.timesAsked += 1
}
