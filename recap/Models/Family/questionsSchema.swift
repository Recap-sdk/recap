//
//  questionsSchema.swift
//  recap
//
//  Created by user@47 on 06/02/25.
//

import UIKit
import Foundation
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
    case familyAdded
    case nutrition
    case fitnessExercise
    case socialInteraction
    case moodEmotion
    case personalHygiene
    case medicationManagement
    case cognitiveExercises
    case outdoorActivities
}

enum QuestionType: String, Codable {
    case multipleChoice
    case singleCorrect
    case yesNo
    case audio
    case image
    case openEnded
    case ratingScale
    case fillInTheBlank
    case matching
    case sorting
    case trueFalse
    case slider
    case dragAndDrop
    case sequence
}

struct Question: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var category: QuestionCategory
    var subcategory: QuestionSubcategory
    var tag: String?
    var answerOptions: [String]
    var answers: [String]
    var correctAnswers: [String]?
    var image: String?
    var isAnswered: Bool
    var askInterval: TimeInterval
    var lastAsked: Date?
    var timesAsked: Int
    var timesAnsweredCorrectly: Int
    var timeFrame: TimeFrame
    var createdAt: Date?
    var addedAt: Date?
    var priority: Int
    var audio: String?
    var isActive: Bool
    var lastAnsweredCorrectly: Date?
    var hint: String?
    var confidence: Int?
    var hardness: Int
    var questionType: QuestionType

    init(
        text: String,
        category: QuestionCategory,
        subcategory: QuestionSubcategory,
        tag: String?,
        answerOptions: [String],
        answers: [String],
        correctAnswers: [String]?,
        image: String?,
        isAnswered: Bool,
        askInterval: TimeInterval,
        timeFrame: TimeFrame,
        priority: Int,
        audio: String?,
        isActive: Bool,
        hint: String?,
        confidence: Int?,
        hardness: Int,
        questionType: QuestionType
    ) {
        self.text = text
        self.category = category
        self.subcategory = subcategory
        self.tag = tag
        self.answerOptions = answerOptions
        self.answers = answers
        self.correctAnswers = correctAnswers
        self.image = image
        self.isAnswered = isAnswered
        self.askInterval = askInterval
        self.lastAsked = nil
        self.timesAsked = 0
        self.timesAnsweredCorrectly = 0
        self.timeFrame = timeFrame
        self.createdAt = Date()
        self.addedAt = nil
        self.priority = priority
        self.audio = audio
        self.isActive = isActive
        self.lastAnsweredCorrectly = nil
        self.hint = hint
        self.confidence = confidence
        self.hardness = hardness
        self.questionType = questionType
    }
}

// MARK: - To Add new questions to Questions collection
//class DailyQuestionsViewController: UIViewController {
//
//    var activityIndicator: UIActivityIndicatorView?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupActivityIndicator()
//        addQuestionsToFirestore()
//    }
//
//    func setupActivityIndicator() {
//        activityIndicator = UIActivityIndicatorView(style: .large)
//        activityIndicator?.center = view.center
//        activityIndicator?.hidesWhenStopped = true
//        view.addSubview(activityIndicator!)
//        activityIndicator?.startAnimating()
//    }
//
//    func addQuestionsToFirestore() {
//        let db = Firestore.firestore()
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm"
//
//        let questions: [Question] = [
//            Question(
//                text: "Did you take your morning medication today?",
//                category: .immediateMemory,
//                subcategory: .medicationManagement,
//                tag: "Medication",
//                answerOptions: ["Yes", "No", "Not Sure"],
//                answers: [],
//                correctAnswers: [],
//                image: nil,
//                isAnswered: false,
//                askInterval: 14400,
//                timeFrame: TimeFrame(from: "06:00", to: "11:59"), // Only time, stored as Timestamp
//                priority: 1,
//                audio: nil,
//                isActive: true,
//                hint: "Check your medication box!",
//                confidence: nil,
//                hardness: 2,
//                questionType: .yesNo
//            ),
//
//            Question(
//                text: "What did you eat for breakfast this morning?",
//                category: .immediateMemory,
//                subcategory: .nutrition,
//                tag: "Eating",
//                answerOptions: ["Cereal", "Eggs", "Toast", "Fruits", "Other"], // Added meaningful options
//                answers: [],
//                correctAnswers: [],
//                image: nil,
//                isAnswered: false,
//                askInterval: 21600,
//                timeFrame: TimeFrame(from: "06:00", to: "11:00"), // Only time, stored as Timestamp
//                priority: 1,
//                audio: nil,
//                isActive: true,
//                hint: "Think back to your morning meal!",
//                confidence: nil,
//                hardness: 3,
//                questionType: .multipleChoice // Changed from `openEnded` to `multipleChoice` to match the options
//            )
//        ]
//
//
//
//
//        for question in questions {
//            var questionData: [String: Any] = [
//                "text": question.text,
//                "category": question.category.rawValue,
//                "subcategory": question.subcategory.rawValue,
//                "tag": question.tag ?? NSNull(),
//                "answerOptions": question.answerOptions,
//                "answers": question.answers,
//                "correctAnswers": question.correctAnswers ?? NSNull(),
//                "image": question.image ?? NSNull(),
//                "isAnswered": question.isAnswered,
//                "askInterval": question.askInterval,
//                "lastAsked": question.lastAsked ?? NSNull(),
//                "timesAsked": question.timesAsked,
//                "timesAnsweredCorrectly": question.timesAnsweredCorrectly,
//                "timeFrame": [
//                    "from": dateFormatter.string(from: question.timeFrame.from.dateValue()),
//                    "to": dateFormatter.string(from: question.timeFrame.to.dateValue())
//                ],
//                "createdAt": question.createdAt,
//                "addedAt": NSNull(),
//                "priority": question.priority,
//                "audio": question.audio ?? NSNull(),
//                "isActive": question.isActive,
//                "lastAnsweredCorrectly": question.lastAnsweredCorrectly ?? NSNull(),
//                "hint": question.hint ?? NSNull(),
//                "confidence": question.confidence ?? NSNull(),
//                "hardness": question.hardness,
//                "questionType": question.questionType.rawValue
//            ]
//
//            db.collection("Questions").addDocument(data: questionData) { error in
//                if let error = error {
//                    print("Error adding question: \(error.localizedDescription)")
//                } else {
//                    print("Question successfully added to Firestore.")
//                }
//            }
//        }
//
//        DispatchQueue.main.async {
//            self.activityIndicator?.stopAnimating()
//        }
//    }
//}

// MARK: - Utility Functions
//func shouldAskQuestion(question: Question, currentDate: Date) -> Bool {
//    guard let lastAsked = question.lastAsked else {
//        return true
//    }
//    return currentDate.timeIntervalSince(lastAsked) >= question.askInterval
//}
//
//func updateAskInterval(for question: inout Question, wasAnsweredCorrectly: Bool) {
//    if wasAnsweredCorrectly {
//        question.askInterval *= 1.5
//        question.timesAnsweredCorrectly += 1
//    } else {
//        question.askInterval = max(3600, question.askInterval / 2)
//    }
//    question.timesAsked += 1
//}
