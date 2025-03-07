//
//  ImmediateDataModel.swift
//  recap
//
//  Created by user@47 on 26/02/25.
//

import Foundation
import SwiftUI
import Firebase

struct ImmediateMemoryData: Identifiable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
    let incorrectAnswers: Int
    var status: MemoryStatus
}


let immediateMemoryData = [
    ImmediateMemoryData(date: Date(), correctAnswers: 8, incorrectAnswers: 2, status: .improving),
]

func evaluateAndStoreMemoryReport(for verifiedUserDocID: String, completion: @escaping () -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(verifiedUserDocID)
    
    let reportsRef = userRef.collection("reports")
    let immediateMemoryRef = reportsRef.document("immediateMemory")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())
    
    let dateRef = immediateMemoryRef.collection(dateString).document("summary")

    // Step 1: Ensure `reports` and `immediateMemory` collections exist
    immediateMemoryRef.setData(["initialized": true], merge: true) { error in
        if let error = error {
            print("❌ Error creating 'immediateMemory' collection: \(error.localizedDescription)")
            completion()
            return
        }
        
        print("✅ 'immediateMemory' collection ensured.")

        // Step 2: Fetch existing questions
        let userQuestionsRef = userRef.collection("questions")

        userQuestionsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching existing questions: \(error.localizedDescription)")
                completion()
                return
            }

            guard let snapshot = snapshot, !snapshot.isEmpty else {
                print("⚠️ No existing questions found.")
                completion()
                return
            }

            var correctCount = 0
            var incorrectCount = 0

            for document in snapshot.documents {
                let data = document.data()
                let correctAnswers = data["correctAnswers"] as? [String] ?? []
                let userAnswers = data["Answers"] as? [String] ?? []

                let matchCount = userAnswers.filter { correctAnswers.contains($0) }.count

                if matchCount == userAnswers.count && matchCount > 0 {
                    correctCount += 1
                } else {
                    incorrectCount += 1
                }
            }

            // Step 3: Store results in `YYYY-MM-DD` collection
            let reportData: [String: Any] = [
                "correctAnswers": correctCount,
                "incorrectAnswers": incorrectCount,
                "timestamp": Timestamp(date: Date())
            ]

            dateRef.setData(reportData, merge: true) { error in
                if let error = error {
                    print("❌ Error storing memory report: \(error.localizedDescription)")
                } else {
                    print("✅ Memory report stored successfully for \(dateString)")
                }
                completion()
            }
        }
    }
}


func fetchImmediateMemoryData(for verifiedUserDocID: String, completion: @escaping ([ImmediateMemoryData]) -> Void) {
    let db = Firestore.firestore()
   

    
    // Format today's date in YYYY-MM-DD format to match Firestore structure
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let todayDateString = dateFormatter.string(from: Date())

    // Correct Firestore path
    let userRef = db.collection("users").document(verifiedUserDocID).collection("reports")       // Collection
        .document("immediateMemory") // Document
        .collection(todayDateString) // Collection (Dynamic Date)
        .document("summary")         // Document (where data is stored)
        
    print("🔍 Fetching Firestore document from path: \(userRef.path)")

    userRef.getDocument { snapshot, error in
        if let error = error {
            print("❌ Firestore fetch error: \(error.localizedDescription)")
            completion([])
            return
        }

        guard let document = snapshot, document.exists, let data = document.data() else {
            print("⚠️ No immediate memory data found at path: \(userRef.path)")
            completion([])
            return
        }

        print("✅ Document found: \(data)")

        let timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        let date = timestamp.dateValue()
        let correctAnswers = data["correctAnswers"] as? Int ?? 0
        let incorrectAnswers = data["incorrectAnswers"] as? Int ?? 0
        let status: MemoryStatus = correctAnswers >= incorrectAnswers ? .improving : .declining

        let memoryData = ImmediateMemoryData(date: date, correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers, status: status)

        print("✅ Parsed memory data: \(memoryData)")

        completion([memoryData])
    }
}
