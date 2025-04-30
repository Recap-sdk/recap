//
//  ImmediateDataModel.swift
//  recap
//
//  Created by s1834 on 26/02/25.
//

import Foundation
import Firebase

struct ImmediateMemoryData: Identifiable {
    let id = UUID()
    let date: Date
    let correctAnswers: Int
    let incorrectAnswers: Int
    var status: MemoryStatus
}

func evaluateAndStoreMemoryReport(for verifiedUserDocID: String, completion: @escaping () -> Void) {
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(verifiedUserDocID)
    let immediateMemoryRef = userRef.collection("reports").document("immediateMemory")
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = dateFormatter.string(from: Date())
    let dateRef = immediateMemoryRef.collection(dateString).document("summary")

    immediateMemoryRef.setData(["initialized": true], merge: true) { error in
        if let error = error {
            print("❌❌ Error creating 'immediateMemory' collection: \(error.localizedDescription)")
            completion()
            return
        }

        let userQuestionsRef = userRef.collection("questions")
        userQuestionsRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌❌ Error fetching existing questions: \(error.localizedDescription)")
                completion()
                return
            }

            guard let snapshot = snapshot, !snapshot.isEmpty else {
                print("⚠️⚠️ No existing questions found.")
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
            
            let reportData: [String: Any] = [
                "correctAnswers": correctCount,
                "incorrectAnswers": incorrectCount,
                "timestamp": Timestamp(date: Date())
            ]

            dateRef.setData(reportData, merge: true) { error in
                if let error = error {
                    print("❌❌ Error storing memory report: \(error.localizedDescription)")
                }
                completion()
            }
        }
    }
}

func fetchImmediateMemoryData(for verifiedUserDocID: String, completion: @escaping ([ImmediateMemoryData]) -> Void) {
    let db = Firestore.firestore()
    
    // Reference to the user's reports collection
    let reportsPath = db.collection("users").document(verifiedUserDocID)
                        .collection("reports").document("immediateMemory")
    
    // First approach: Query all documents that contain memory data
    // We need to use a different approach since documentReference.listCollections is not available
    
    // Get the base path for reports
    let basePath = "users/\(verifiedUserDocID)/reports/immediateMemory"
    
    // Create a date formatter for consistent date handling
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let todayDateString = dateFormatter.string(from: Date())
    
    // We'll use a known pattern to fetch all date collections
    // This requires knowing the date range to check
    
    // Get dates for the last 90 days to check
    var datesToCheck: [String] = []
    let calendar = Calendar.current
    let today = Date()
    
    for dayOffset in 0..<90 {
        if let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) {
            let dateString = dateFormatter.string(from: date)
            datesToCheck.append(dateString)
        }
    }
    
    // Use dispatch group to handle multiple async calls
    let group = DispatchGroup()
    var allMemoryData: [ImmediateMemoryData] = []
    
    // Check each potential date path
    for dateString in datesToCheck {
        group.enter()
        
        let datePath = "\(basePath)/\(dateString)/summary"
        let docRef = db.document(datePath)
        
        docRef.getDocument { (document, error) in
            defer { group.leave() }
            
            if let error = error {
                print("❌ Error checking \(dateString): \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                // No data for this date, which is expected for most dates
                return
            }
            
            // We found data for this date!
            let timestamp = data["timestamp"] as? Timestamp
            let date: Date
            
            if let timestamp = timestamp {
                date = timestamp.dateValue()
            } else if let parsedDate = dateFormatter.date(from: dateString) {
                date = parsedDate
            } else {
                date = today
            }
            
            let correctAnswers = data["correctAnswers"] as? Int ?? 0
            let incorrectAnswers = data["incorrectAnswers"] as? Int ?? 0
            let status: MemoryStatus = correctAnswers >= incorrectAnswers ? .improving : .declining
            
            let memoryData = ImmediateMemoryData(
                date: date,
                correctAnswers: correctAnswers,
                incorrectAnswers: incorrectAnswers,
                status: status
            )
            
            // Add to our results
            allMemoryData.append(memoryData)
            print("✅ Found data for \(dateString): correct=\(correctAnswers), incorrect=\(incorrectAnswers)")
        }
    }
    
    // When all checks complete, sort and return the data
    group.notify(queue: .main) {
        // Sort by date, most recent first
        let sortedData = allMemoryData.sorted(by: { $0.date > $1.date })
        print("✅ Successfully fetched \(sortedData.count) memory data entries")
        completion(sortedData)
    }
}
