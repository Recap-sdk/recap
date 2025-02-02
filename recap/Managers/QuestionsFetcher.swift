//
//  QuestionsFetcher.swift
//  recap
//
//  Created by user@47 on 03/02/25.
//

import FirebaseFirestore

class QuestionsFetcher {
    var verifiedUserDocID: String = "hOK9UY6qgeS44tRF6btySWU3e7a2"  // Ensure this is dynamically assigned
    
    func fetchQuestions(completion: @escaping ([Question]) -> Void) {
        let db = Firestore.firestore()
        let questionsRef = db.collection("Questions")
        
        let immediateMemoryRef = questionsRef.whereField("category", isEqualTo: "immediateMemory").limit(to: 7)
        let recentMemoryRef = questionsRef.whereField("category", isEqualTo: "recentMemory").limit(to: 5)
        let remoteMemoryRef = questionsRef.whereField("category", isEqualTo: "remoteMemory").limit(to: 2)
        
        let group = DispatchGroup()
        
        var immediateMemoryQuestions: [Question] = []
        var recentMemoryQuestions: [Question] = []
        var remoteMemoryQuestions: [Question] = []
        
        group.enter()
        immediateMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching immediate memory questions: \(error.localizedDescription)")
            } else {
                immediateMemoryQuestions = snapshot?.documents.compactMap { self.convertToQuestion(doc: $0) } ?? []
            }
            group.leave()
        }
        
        group.enter()
        recentMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching recent memory questions: \(error.localizedDescription)")
            } else {
                recentMemoryQuestions = snapshot?.documents.compactMap { self.convertToQuestion(doc: $0) } ?? []
            }
            group.leave()
        }
        
        group.enter()
        remoteMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching remote memory questions: \(error.localizedDescription)")
            } else {
                remoteMemoryQuestions = snapshot?.documents.compactMap { self.convertToQuestion(doc: $0) } ?? []
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            let allQuestions = immediateMemoryQuestions + recentMemoryQuestions + remoteMemoryQuestions
            completion(allQuestions)
        }
    }
    
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

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let lastAsked = dateFormatter.date(from: lastAskedString ?? "")

        let timeInterval: TimeInterval = TimeInterval(askInterval)

        return Question(
            id: doc.documentID,
            text: text,
            category: category,
            subcategory: QuestionSubcategory(rawValue: subcategory) ?? .general,
            tag: tag,
            answerOptions: answerOptions,
            image: image,
            isAnswered: isAnswered,
            askInterval: timeInterval,
            lastAsked: lastAsked,
            timesAsked: timesAsked,
            timesAnsweredCorrectly: timesAnsweredCorrectly
        )
    }
}
