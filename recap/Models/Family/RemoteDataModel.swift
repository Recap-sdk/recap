//
//  RemoteDataModel.swift
//  Recap
//
//  Created by khushi on 29/10/24.
//

import Foundation
import FirebaseFirestore

struct RemoteMemoryData: Identifiable, Equatable {
    let id = UUID()
    let day: String
    let correctAnswers: Int
    let incorrectAnswers: Int

    static func == (lhs: RemoteMemoryData, rhs: RemoteMemoryData) -> Bool {
        return lhs.day == rhs.day &&
               lhs.correctAnswers == rhs.correctAnswers &&
               lhs.incorrectAnswers == rhs.incorrectAnswers
    }
}

let DEFAULT_MEMORY_DATA: [String: Any] = [
    "correct": 0,
    "incorrect": 0,
    "averageScore": 0.0,
    "createdAt": Timestamp()
]

func fetchRemoteMemoryData(for userID: String, month: String, completion: @escaping ([RemoteMemoryData]) -> Void) {
    let db = Firestore.firestore()
    let monthRef = db.collection("users").document(userID).collection("reports").document("remoteMemory").collection(month)

    ensureSubcollectionExists(for: userID, collection: "remoteMemory", month: month) { exists in
        guard exists else {
            completion([])
            return
        }

        monthRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌❌ Error fetching remote memory data: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                completion([])
                return
            }

            var fetchedData: [RemoteMemoryData] = []

            for document in documents {
                let data = document.data()
                let day = document.documentID

                if let correct = data["correct"] as? Int,
                   let incorrect = data["incorrect"] as? Int {
                    
                    let entry = RemoteMemoryData(day: day, correctAnswers: correct, incorrectAnswers: incorrect)
                    fetchedData.append(entry)
                }
            }
            
            if fetchedData.isEmpty {
                fetchedData = (1...30).map { day in
                    RemoteMemoryData(day: String(format: "%02d", day), correctAnswers: 0, incorrectAnswers: 0)
                }
            }
            completion(fetchedData)
        }
    }
}

    
func fetchAndCalculateRecentMemory(for userID: String, month: String, completion: @escaping ([RemoteMemoryData]) -> Void) {
    ensureSubcollectionExists(for: userID, collection: "recentMemory", month: month) { exists in
        guard exists else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        let recentMemoryRef = db.collection("users").document(userID)
            .collection("reports").document("recentMemory")
            .collection(month)

        recentMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌❌ Error fetching recent memory data: \(error.localizedDescription)")
                completion([])
                return
            }

            var weeklyData: [RemoteMemoryData] = []

            for document in snapshot?.documents ?? [] {
                let data = document.data()

                if let days = data["days"] as? [String: [String: Any]] {
                    for (day, values) in days {
                        let correct = values["correct"] as? Int ?? 0
                        let incorrect = values["incorrect"] as? Int ?? 0

                        let memoryData = RemoteMemoryData(day: day, correctAnswers: correct, incorrectAnswers: incorrect)
                        weeklyData.append(memoryData)
                    }
                }
            }
            completion(weeklyData)
        }
    }
}

func calculateFromRecentMemory(weeklyData: [RemoteMemoryData]) -> Double {
    guard !weeklyData.isEmpty else {
        return 0.0
    }
    let totalCorrect = weeklyData.reduce(0) { $0 + $1.correctAnswers }
    let totalIncorrect = weeklyData.reduce(0) { $0 + $1.incorrectAnswers }
    let totalAnswers = totalCorrect + totalIncorrect
    let averageScore = totalAnswers > 0 ? (Double(totalCorrect) / Double(totalAnswers)) * 100 : 0.0
    return averageScore
}

func ensureSubcollectionExists(for userID: String, collection: String, month: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let reportsRef = db.collection("users").document(userID).collection("reports").document(collection).collection(month)

    reportsRef.document("summary").getDocument { snapshot, error in
        if let error = error {
            print("❌❌ Error checking \(collection)/\(month): \(error.localizedDescription)")
            completion(false)
            return
        }

        if snapshot?.exists == false {
            var defaultData = DEFAULT_MEMORY_DATA
            defaultData["createdAt"] = Timestamp()

            reportsRef.document("summary").setData(defaultData) { error in
                if let error = error {
                    print("❌❌ Error: Failed to create summary: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        } else {
            completion(true)
        }
    }
}

func saveRemoteMemoryData(userID: String, month: String, weeklyData: [RemoteMemoryData]) {
    let db = Firestore.firestore()
    let monthRef = db.collection("users").document(userID).collection("reports").document("remoteMemory").collection(month)

    let totalCorrect = weeklyData.reduce(0) { $0 + $1.correctAnswers }
    let totalIncorrect = weeklyData.reduce(0) { $0 + $1.incorrectAnswers }
    let totalAnswers = totalCorrect + totalIncorrect
    let averageScore = totalAnswers > 0 ? (Double(totalCorrect) / Double(totalAnswers)) * 100 : 0.0

    let summaryRef = monthRef.document("summary")

    summaryRef.getDocument { snapshot, _ in
        let existingCreatedAt = snapshot?.data()?["createdAt"] ?? Timestamp()
        let summaryData: [String: Any] = ["correct": totalCorrect, "incorrect": totalIncorrect, "averageScore": averageScore, "createdAt": existingCreatedAt]

        summaryRef.setData(summaryData, merge: true) { error in
            if let error = error {
                print("❌❌ Error saving remote memory summary: \(error.localizedDescription)")
            }
        }
    }

    let allDays = (1...31).map { String(format: "%02d", $0) }
    let existingDataDict = Dictionary(uniqueKeysWithValues: weeklyData.map { ($0.day, $0) })

    for day in allDays {
        let dayRef = monthRef.document(day)
        
        dayRef.getDocument { snapshot, _ in
            let existingCreatedAt = snapshot?.data()?["createdAt"] ?? Timestamp()
            let memoryData = existingDataDict[day] ?? RemoteMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)

            let dayData: [String: Any] = ["correct": memoryData.correctAnswers, "incorrect": memoryData.incorrectAnswers, "createdAt": existingCreatedAt]

            dayRef.setData(dayData, merge: true) { error in
                if let error = error {
                    print("❌ Error saving data for \(memoryData.day): \(error.localizedDescription)")
                }
            }
        }
    }
}
