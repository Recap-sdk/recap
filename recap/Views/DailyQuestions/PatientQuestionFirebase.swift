//
//  PatientQuestionFirebase.swift
//  recap
//
//  Created by s1834 on 13/03/25.
//

import FirebaseFirestore

extension PatientQuestionViewController {

    func fetchQuestionsFromFirestore() {
          let userQuestionsRef = db.collection("users").document(verifiedUserDocID).collection("questions")
          userQuestionsRef.getDocuments { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
              guard let self = self else { return }
              
              if let error = error {
                  print("❌❌ Error fetching questions: \(error.localizedDescription)")
                  return
              }

              self.questions = snapshot?.documents.compactMap { document in
                  var question = try? document.data(as: Question.self)
                  question?.id = document.documentID
                  return question
              } ?? []

              if self.questions.isEmpty {
                  self.showNoQuestionsReadyAlert()
                  return
              }

              self.sortQuestions()
              self.askAllQuestions()
          }
      }
    
    private func askAllQuestions() {
          var displayedAny = false

          for question in questions {
              if shouldAskQuestionAgain(for: question) {
                  displayQuestion(question)
                  displayedAny = true
                  break
              }
          }

          if !displayedAny {
              showNoQuestionsReadyAlert()
          }
      }

    private func sortQuestions() {
            self.questions.sort { (q1, q2) -> Bool in
                if !q1.isAnswered && q2.isAnswered { return true }
                if q1.isAnswered && !q2.isAnswered { return false }
                return q1.priority < q2.priority
            }
        }

    private func shouldAskQuestionAgain(for question: Question) -> Bool {
           if !question.isAnswered {
               return true
           }
           
           if let lastAsked = question.lastAsked {
               let nextAskTime = lastAsked.addingTimeInterval(TimeInterval(question.askInterval))
               if Date() >= nextAskTime {
                   return true
               }
           }
           return false
       }
   

    func updateStreakAndAnalytics() {
        let streakService = StreakService(verifiedUserDocID: verifiedUserDocID)
        streakService.updateStreakForToday(with: true)

        // Update lastAnswered in analytics
        let analyticsRef = db.collection("users").document(verifiedUserDocID).collection("core").document("analytics")
        analyticsRef.updateData(["lastAnswered": Date()]) { error in
            if let error = error {
                print("❌❌ Error updating lastAnswered: \(error.localizedDescription)")
            }
        }

        // Update streak data in streaksCore
        let streaksCoresRef = db.collection("users").document(verifiedUserDocID).collection("streaksCore").document("streakData")
        streaksCoresRef.getDocument { document, error in
            if let error = error {
                print("❌❌ Error fetching streak data: \(error.localizedDescription)")
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

                if lastAnsweredDay != today {
                    let updatedMaxStreak = max(currentStreak + 1, maxStreak)
                    streaksCoresRef.updateData([
                        "activeDays": FieldValue.increment(Int64(1)),
                        "currentStreak": FieldValue.increment(Int64(1)),
                        "maxStreak": updatedMaxStreak,
                        "lastAnswered": Timestamp(date: Date())
                    ]) { error in
                        if let error = error {
                            print("❌❌ Error updating streak data: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    private func updateQuestionLastAsked(_ question: Question) {
        let questionRef = db.collection("users").document(verifiedUserDocID).collection("questions").document(question.id!)
        questionRef.updateData([
            "lastAsked": Date()
        ])
    }
}
