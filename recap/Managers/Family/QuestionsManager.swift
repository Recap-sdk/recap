//
//  QuestionsManager.swift
//  recap
//
//  Created by s1834 on 03/02/25.
//


import FirebaseFirestore

class QuestionsManager {
    var verifiedUserDocID: String
    var timer: Timer?

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
    }

    // MARK: - Fetch Questions
    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")

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
                    self.fetchQuestionsByDateIfNeeded(completion: completion)
                    return
                }

                var allQuestions = documents.compactMap { doc -> Question? in
                    var question = self.convertToQuestion(doc: doc)
                    question?.id = doc.documentID
                    return question
                }
                allQuestions.shuffle()

                var immediateMemoryQuestions: [Question] = []
                var recentQuestions: [Question] = []
                var remoteQuestions: [Question] = []

                for question in allQuestions {
                    guard let questionID = question.id, !existingQuestionIDs.contains(questionID) else { continue }

                    switch question.category.rawValue {
                        case "immediateMemory": immediateMemoryQuestions.append(question)
                        case "recentMemory": recentQuestions.append(question)
                        case "remoteMemory": remoteQuestions.append(question)
                        default: break
                    }
                }

                let selectedImmediate = Array(immediateMemoryQuestions.prefix(4))
                let selectedRecent = Array(recentQuestions.prefix(2))
                let selectedRemote = Array(remoteQuestions.prefix(1))

                var finalQuestions = selectedImmediate + selectedRecent + selectedRemote

                if finalQuestions.isEmpty {
                    self.fetchQuestionsByDateIfNeeded(completion: completion)
                } else {
                    self.sendQuestionsToUser(questions: finalQuestions)
                    completion(finalQuestions)
                }
            }
        }
    }

    func moveQuestionsToAskedAndDelete(completion: @escaping () -> Void) {
        ensureQuestionsAskedExists {
            let db = Firestore.firestore()
            let userQuestionsRef = db.collection("users").document(self.verifiedUserDocID).collection("questions")
            let calendar = Calendar.current
            let date = Date()
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let monthFormatted = String(format: "%02d", month) // Ensure month is "01", "02", ..., "12"
            let dayFormatted = String(format: "%02d", day) // Ensure day is "01", "02", ..., "31"
            
            let monthPath = "\(year)-\(monthFormatted)"
            let dayPath = "\(year)-\(monthFormatted)-\(dayFormatted)"

            let questionsAskedRef = db.collection("users")
                .document(self.verifiedUserDocID)
                .collection("questionsAsked")
                .document("\(year)")
                .collection(monthPath)
                .document(dayPath)

            userQuestionsRef.getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching user questions: \(error.localizedDescription)")
                    completion()
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("✅ No questions to move.")
                    completion()
                    return
                }

                let batch = db.batch()

                for document in documents {
                    let questionID = document.documentID
                    let questionData = document.data()

                    let questionAskedRef = questionsAskedRef.collection(questionID).document("data")
                    batch.setData(questionData, forDocument: questionAskedRef)

                    let questionRef = userQuestionsRef.document(questionID)
                    batch.deleteDocument(questionRef)
                }

                batch.commit { batchError in
                    if let batchError = batchError {
                        print("❌ Error committing batch: \(batchError.localizedDescription)")
                    }
                    completion()
                }
            }
        }
    }

    func ensureQuestionsAskedExists(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let date = Date()
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        let monthFormatted = String(format: "%02d", month)
        let dayFormatted = String(format: "%02d", day)
        
        let monthPath = "\(year)-\(monthFormatted)"
        let dayPath = "\(year)-\(monthFormatted)-\(dayFormatted)"

        let questionsAskedRef = db.collection("users")
            .document(verifiedUserDocID)
            .collection("questionsAsked")
            .document("\(year)")
            .collection(monthPath)
            .document(dayPath)

        questionsAskedRef.getDocument { document, error in
            if let error = error {
                print("Error checking questionsAsked existence: \(error.localizedDescription)")
                return
            }

            if document?.exists == true {
                completion()
            } else {
                questionsAskedRef.setData([:]) { error in
                    if let error = error {
                        print("Error creating questionsAsked: \(error.localizedDescription)")
                    } else {
                        completion()
                    }
                }
            }
        }
    }


    func fetchQuestionsByDateIfNeeded(completion: @escaping ([Question]) -> Void) {
        let db = Firestore.firestore()
        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")

        userQuestionsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user questions: \(error.localizedDescription)")
                completion([])
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                let questions = documents.compactMap { self.convertToQuestion(doc: $0) }
                completion(questions)
                return
            }

            let calendar = Calendar.current
            let date = Date()
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)

            let questionsAskedRef = db.collection("users")
                .document(self.verifiedUserDocID)
                .collection("questionsAsked")
                .document("\(year)")
                .collection("\(month)")
                .document("\(year)-\(month)-\(day)")

            questionsAskedRef.collection("questions").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching questions from questionsAsked: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No questions found in questionsAsked.")
                    completion([])
                    return
                }

                let questions = documents.compactMap { self.convertToQuestion(doc: $0) }
                completion(questions)
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

            userQuestionsRef.document(questionID).setData(["text": question.text, "category": question.category.rawValue, "subcategory": question.subcategory.rawValue, "tag": question.tag, "answerOptions": question.answerOptions, "answers": question.answers, "correctAnswers": question.correctAnswers, "image": question.image ?? NSNull(), "isAnswered": question.isAnswered, "askInterval": question.askInterval, "lastAsked": NSNull(), "timesAsked": question.timesAsked, "timesAnsweredCorrectly": question.timesAnsweredCorrectly, "timeFrame": [ "from": question.timeFrame.from, "to": question.timeFrame.to], "priority": question.priority, "audio": question.audio ?? NSNull(), "isActive": question.isActive, "lastAnsweredCorrectly": question.lastAnsweredCorrectly ?? NSNull(), "hint": question.hint ?? NSNull(), "confidence": question.confidence ?? NSNull(), "hardness": question.hardness, "questionType": question.questionType.rawValue, "addedAt": FieldValue.serverTimestamp(), "createdAt": question.createdAt], merge: true) { error in
                if let error = error {
                    print("Error adding question to user: \(error.localizedDescription)")
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
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

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

        return Question(text: text, category: category, subcategory: QuestionSubcategory(rawValue: subcategory) ?? .general, tag: tag, answerOptions: answerOptions, answers: answers, correctAnswers: correctAnswers, image: image, isAnswered: isAnswered, askInterval: TimeInterval(askInterval), timeFrame: timeFrame, priority: priority, audio: audio, isActive: isActive, hint: hint, confidence: confidence, hardness: hardness, questionType: questionType)
    }
}

//import FirebaseFirestore
//
//class QuestionsManager {
//    var verifiedUserDocID: String
//    var timer: Timer?
//
//    init(verifiedUserDocID: String) {
//        self.verifiedUserDocID = verifiedUserDocID
//    }
//
//    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
//        let db = Firestore.firestore()
//        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")
//
//        userQuestionsRef.getDocuments { userSnapshot, userError in
//            if let userError = userError {
//                print("Error fetching user questions: \(userError.localizedDescription)")
//                completion([])
//                return
//            }
//
//            let existingQuestionIDs = Set(userSnapshot?.documents.map { $0.documentID } ?? [])
//
//            let questionsRef = db.collection("Questions")
//            questionsRef.getDocuments { snapshot, error in
//                if let error = error {
//                    print("Error fetching new questions: \(error.localizedDescription)")
//                    completion([])
//                    return
//                }
//
//                guard let documents = snapshot?.documents else {
//                    print("No new questions found")
//                    completion([])
//                    return
//                }
//
//                var allQuestions = documents.compactMap { doc -> Question? in
//                    var question = self.convertToQuestion(doc: doc)
//                    question?.id = doc.documentID
//                    return question
//                }
//                allQuestions.shuffle()
//
//                var immediateMemoryQuestions: [Question] = []
//                var recentQuestions: [Question] = []
//                var remoteQuestions: [Question] = []
//
//                for question in allQuestions {
//                    guard let questionID = question.id, !existingQuestionIDs.contains(questionID) else { continue }
//
//                    switch question.category.rawValue {
//                        case "immediateMemory": immediateMemoryQuestions.append(question)
//                        case "recentMemory": recentQuestions.append(question)
//                        case "remoteMemory": remoteQuestions.append(question)
//                        default: break
//                    }
//                }
//
//                let selectedImmediate = Array(immediateMemoryQuestions.prefix(4))
//                let selectedRecent = Array(recentQuestions.prefix(2))
//                let selectedRemote = Array(remoteQuestions.prefix(1))
//
//                var finalQuestions = selectedImmediate + selectedRecent + selectedRemote
//
//                self.sendQuestionsToUser(questions: finalQuestions)
//                completion(finalQuestions)
//            }
//        }
//    }
//
//    private func sendQuestionsToUser(questions: [Question]) {
//        let db = Firestore.firestore()
//        let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")
//
//        for question in questions {
//            guard let questionID = question.id, !questionID.isEmpty else {
//                print("Skipping question due to empty ID: \(question)")
//                continue
//            }
//
//            userQuestionsRef.document(questionID).setData(["text": question.text, "category": question.category.rawValue, "subcategory": question.subcategory.rawValue, "tag": question.tag, "answerOptions": question.answerOptions, "answers": question.answers, "correctAnswers": question.correctAnswers, "image": question.image ?? NSNull(), "isAnswered": question.isAnswered, "askInterval": question.askInterval, "lastAsked": NSNull(), "timesAsked": question.timesAsked, "timesAnsweredCorrectly": question.timesAnsweredCorrectly, "timeFrame": [ "from": question.timeFrame.from, "to": question.timeFrame.to], "priority": question.priority, "audio": question.audio ?? NSNull(), "isActive": question.isActive, "lastAnsweredCorrectly": question.lastAnsweredCorrectly ?? NSNull(), "hint": question.hint ?? NSNull(), "confidence": question.confidence ?? NSNull(), "hardness": question.hardness, "questionType": question.questionType.rawValue, "addedAt": FieldValue.serverTimestamp(), "createdAt": question.createdAt], merge: true) { error in
//                if let error = error {
//                    print("Error adding question to user: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//
//    private func convertToQuestion(doc: QueryDocumentSnapshot) -> Question? {
//        let data = doc.data()
//
//        guard let categoryString = data["category"] as? String,
//              let category = QuestionCategory(rawValue: categoryString),
//              let text = data["text"] as? String else {
//            print("Invalid data for document \(doc.documentID)")
//            return nil
//        }
//
//        let subcategory = data["subcategory"] as? String ?? ""
//        let answerOptions = data["answerOptions"] as? [String] ?? []
//        let answers = data["answers"] as? [String] ?? []
//        let correctAnswers = data["correctAnswers"] as? [String] ?? []
//        let tag = data["tag"] as? String ?? ""
//        let image = data["image"] as? String
//        let audio = data["audio"] as? String
//        let hint = data["hint"] as? String
//        let isAnswered = data["isAnswered"] as? Bool ?? false
//        let isActive = data["isActive"] as? Bool ?? true
//        let askInterval = data["askInterval"] as? Int ?? 0
//        let timesAsked = data["timesAsked"] as? Int ?? 0
//        let timesAnsweredCorrectly = data["timesAnsweredCorrectly"] as? Int ?? 0
//        let priority = data["priority"] as? Int ?? 0
//        let hardness = data["hardness"] as? Int ?? 0
//        let confidence = data["confidence"] as? Int
//        let lastAsked = (data["lastAsked"] as? Timestamp)?.dateValue()
//        let lastAnsweredCorrectly = (data["lastAnsweredCorrectly"] as? Timestamp)?.dateValue()
//
//        let dateFormatter = ISO8601DateFormatter()
//        dateFormatter.formatOptions = [.withInternetDateTime]
//
//        let timeFrameData = data["timeFrame"] as? [String: Timestamp]
//        let fromDate = timeFrameData?["from"]?.dateValue() ?? Date()
//        let toDate = timeFrameData?["to"]?.dateValue() ?? Date()
//
//        let timeFrame = TimeFrame(
//            from: dateFormatter.string(from: fromDate),
//            to: dateFormatter.string(from: toDate)
//        )
//
//        let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
//        let addedAt: Timestamp? = data["addedAt"] as? Timestamp
//
//        let questionTypeString = data["questionType"] as? String ?? ""
//        let questionType = QuestionType(rawValue: questionTypeString) ?? .singleCorrect
//
//        return Question(text: text, category: category, subcategory: QuestionSubcategory(rawValue: subcategory) ?? .general, tag: tag, answerOptions: answerOptions, answers: answers, correctAnswers: correctAnswers, image: image, isAnswered: isAnswered, askInterval: TimeInterval(askInterval), timeFrame: timeFrame, priority: priority, audio: audio, isActive: isActive, hint: hint, confidence: confidence, hardness: hardness, questionType: questionType)
//    }
//}
