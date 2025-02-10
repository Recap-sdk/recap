//
//  QuestionsFetcher.swift
//  recap
//
//  Created by user@47 on 03/02/25.
//

import FirebaseFirestore

class QuestionsManager {
    var verifiedUserDocID: String
    var timer: Timer?

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
    }

    func startFetchingQuestions(completion: @escaping ([Question]) -> Void) {
        fetchQuestions(completion: completion)
        
        timer = Timer.scheduledTimer(withTimeInterval: 86400.0, repeats: true) { _ in
            self.fetchQuestions(completion: completion)
        }
    }

    func stopFetchingQuestions() {
        timer?.invalidate()
        timer = nil
    }

    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")
        print("Fetching questions for user: \(verifiedUserDocID)")

        userQuestionsRef.getDocuments { userSnapshot, userError in
            if let userError = userError {
                print("Error fetching user questions: \(userError.localizedDescription)")
                completion([])
                return
            }

            let existingQuestionIDs = Set(userSnapshot?.documents.map { $0.documentID } ?? [])

            let questionsRef = db.collection("Questions")
            questionsRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching new questions: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No new questions found")
                    completion([])
                    return
                }

                // Convert Firestore documents to Question objects and shuffle them
                var allQuestions = documents.compactMap { doc -> Question? in
                    var question = self.convertToQuestion(doc: doc)
                    question?.id = doc.documentID // Assign Firestore document ID
                    return question
                }
                allQuestions.shuffle() // Shuffle before categorization

                // Categorized lists
                var immediateMemoryQuestions: [Question] = []
                var recentQuestions: [Question] = []
                var remoteQuestions: [Question] = []

                for question in allQuestions {
                    guard let questionID = question.id, !existingQuestionIDs.contains(questionID) else { continue }

                    // Categorize questions
                    switch question.category.rawValue {
                        case "immediateMemory": immediateMemoryQuestions.append(question)
                        case "recentMemory": recentQuestions.append(question)
                        case "remoteMemory": remoteQuestions.append(question)
                        default: break
                    }
                }

                // Pick questions from each category
                let selectedImmediate = Array(immediateMemoryQuestions.prefix(4))
                let selectedRecent = Array(recentQuestions.prefix(2))
                let selectedRemote = Array(remoteQuestions.prefix(1))

                var finalQuestions = selectedImmediate + selectedRecent + selectedRemote

//                print("Selected Questions: \(finalQuestions)")

                self.sendQuestionsToUser(questions: finalQuestions)
                completion(finalQuestions)
            }
        }
    }

    private func sendQuestionsToUser(questions: [Question]) {
        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")

        for question in questions {
            guard let questionID = question.id, !questionID.isEmpty else {
                print("Skipping question due to empty ID: \(question)")
                continue
            }

            userQuestionsRef.document(questionID).setData([
                "text": question.text,
                "category": question.category.rawValue,
                "subcategory": question.subcategory.rawValue,
                "tag": question.tag,
                "answerOptions": question.answerOptions,
                "answers": question.answers,
                "correctAnswers": question.correctAnswers,
                "image": question.image ?? NSNull(), // Use NSNull for optional fields that are nil
                "isAnswered": question.isAnswered,
                "askInterval": question.askInterval,
                "lastAsked": NSNull(), // Use NSNull() for null fields
                "timesAsked": question.timesAsked,
                "timesAnsweredCorrectly": question.timesAnsweredCorrectly,
                "timeFrame": [
                    "from": question.timeFrame.from,
                    "to": question.timeFrame.to
                ],
                "priority": question.priority,
                "audio": question.audio ?? NSNull(), // Use NSNull for nil audio
                "isActive": question.isActive,
                "lastAnsweredCorrectly": question.lastAnsweredCorrectly ?? NSNull(),
                "hint": question.hint ?? NSNull(),
                "confidence": question.confidence ?? NSNull(),
                "hardness": question.hardness,
                "questionType": question.questionType.rawValue,
                "addedAt": FieldValue.serverTimestamp(), // This is the timestamp when the question is added to the user
                "createdAt": question.createdAt // This is the timestamp from the original question document
            ], merge: true) { error in
                if let error = error {
                    print("Error adding question to user: \(error.localizedDescription)")
                } else {
                    print("Successfully added question \(questionID) to user")
                }
            }
        }
    }




    private func convertToQuestion(doc: QueryDocumentSnapshot) -> Question? {
        let data = doc.data()

        guard let categoryString = data["category"] as? String,
              let category = QuestionCategory(rawValue: categoryString),
              let text = data["text"] as? String else {
            print("Invalid data for document \(doc.documentID)")
            return nil
        }

        let subcategory = data["subcategory"] as? String ?? ""
        let answerOptions = data["answerOptions"] as? [String] ?? []
        let answers = data["answers"] as? [String] ?? []
        let correctAnswers = data["correctAnswers"] as? [String] ?? []
        
        let tag = data["tag"] as? String ?? ""
        let image = data["image"] as? String
        let audio = data["audio"] as? String
        let hint = data["hint"] as? String
        
        let isAnswered = data["isAnswered"] as? Bool ?? false
        let isActive = data["isActive"] as? Bool ?? true
        
        let askInterval = data["askInterval"] as? Int ?? 0
        let timesAsked = data["timesAsked"] as? Int ?? 0
        let timesAnsweredCorrectly = data["timesAnsweredCorrectly"] as? Int ?? 0
        let priority = data["priority"] as? Int ?? 0
        let hardness = data["hardness"] as? Int ?? 0
        let confidence = data["confidence"] as? Int
        
        let lastAsked = (data["lastAsked"] as? Timestamp)?.dateValue()
        let lastAnsweredCorrectly = (data["lastAnsweredCorrectly"] as? Timestamp)?.dateValue()
        
        // Convert Date to String
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime] // Standard format

        let timeFrameData = data["timeFrame"] as? [String: Timestamp]
        let fromDate = timeFrameData?["from"]?.dateValue() ?? Date()
        let toDate = timeFrameData?["to"]?.dateValue() ?? Date()

        let timeFrame = TimeFrame(
            from: dateFormatter.string(from: fromDate),
            to: dateFormatter.string(from: toDate)
        )

        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        let addedAt: Timestamp? = data["addedAt"] as? Timestamp


        let questionTypeString = data["questionType"] as? String ?? ""
        let questionType = QuestionType(rawValue: questionTypeString) ?? .singleCorrect

        return Question(
            text: text,
            category: category,
            subcategory: QuestionSubcategory(rawValue: subcategory) ?? .general,
            tag: tag,
            answerOptions: answerOptions,
            answers: answers,
            correctAnswers: correctAnswers,
            image: image,
            isAnswered: isAnswered,
            askInterval: TimeInterval(askInterval),
            timeFrame: timeFrame,
            priority: priority,
            audio: audio,
            isActive: isActive,
            hint: hint,
            confidence: confidence,
            hardness: hardness,
            questionType: questionType
        )
    }

}
