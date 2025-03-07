//
//  RemoteDataModel.swift
//  Recap
//
//  Created by admin70 on 29/10/24.
//

import Foundation
import FirebaseFirestore

// MARK: - Models

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
    let monthRef = db.collection("users").document(userID)
        .collection("reports").document("remoteMemory")
        .collection(month)

    // 🛠 Ensure subcollection exists before fetching
    ensureSubcollectionExists(for: userID, collection: "remoteMemory", month: month) { exists in
        guard exists else {
            print("⚠️ Subcollection did not exist, created now.")
            completion([])
            return
        }

        monthRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching remote memory data: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("⚠️ No remote memory data found.")
                completion([])
                return
            }

            var fetchedData: [RemoteMemoryData] = []

            for document in documents {
                let data = document.data()
                let day = document.documentID // Document ID should be day number or "summary"

                if let correct = data["correct"] as? Int,
                   let incorrect = data["incorrect"] as? Int {
                    
                    let entry = RemoteMemoryData(day: day, correctAnswers: correct, incorrectAnswers: incorrect)
                    fetchedData.append(entry)
                }
            }

            print("📊 Successfully fetched \(fetchedData.count) entries including daily data and summary.")
            
            if fetchedData.isEmpty {
                print("⚠️ No daily data found, adding placeholder values.")
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
            print("⚠️ Subcollection does not exist.")
            completion([])
            return
        }

        let db = Firestore.firestore()
        let recentMemoryRef = db.collection("users").document(userID)
            .collection("reports").document("recentMemory")
            .collection(month)

        recentMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("🔥 Error fetching recent memory data: \(error.localizedDescription)")
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

                        print("📊 \(day): Correct - \(correct), Incorrect - \(incorrect)")

                        let memoryData = RemoteMemoryData(day: day, correctAnswers: correct, incorrectAnswers: incorrect)
                        weeklyData.append(memoryData)
                    }
                }
            }

            print("✅ Successfully fetched and processed \(weeklyData.count) days from recentMemory.")
            completion(weeklyData)
        }
    }
}

// MARK: - Calculations

func calculateFromRecentMemory(weeklyData: [RemoteMemoryData]) -> Double {
    guard !weeklyData.isEmpty else {
        print("⚠️ No data available for recent memory calculations.")
        return 0.0
    }

    let totalCorrect = weeklyData.reduce(0) { $0 + $1.correctAnswers }
    let totalIncorrect = weeklyData.reduce(0) { $0 + $1.incorrectAnswers }
    let totalAnswers = totalCorrect + totalIncorrect

    let averageScore = totalAnswers > 0 ? (Double(totalCorrect) / Double(totalAnswers)) * 100 : 0.0

    print("📈 Recent Memory Calculation:")
    print("✔️ Total Correct: \(totalCorrect)")
    print("❌ Total Incorrect: \(totalIncorrect)")
    print("🎯 Average Score: \(averageScore)%")

    return averageScore
}

// MARK: - Firestore Data Saving

func ensureSubcollectionExists(for userID: String, collection: String, month: String, completion: @escaping (Bool) -> Void) {
    let db = Firestore.firestore()
    let reportsRef = db.collection("users").document(userID)
        .collection("reports").document(collection)
        .collection(month)

    reportsRef.document("summary").getDocument { snapshot, error in
        if let error = error {
            print("🔥 Error checking \(collection)/\(month): \(error.localizedDescription)")
            completion(false)
            return
        }

        if snapshot?.exists == false {
            print("⚠️ Summary document missing. Creating default summary...")
            var defaultData = DEFAULT_MEMORY_DATA
            defaultData["createdAt"] = Timestamp() // Set creation time

            reportsRef.document("summary").setData(defaultData) { error in
                if let error = error {
                    print("❌ Failed to create summary: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("✅ Default summary document created for \(collection)/\(month) with timestamp.")
                    completion(true)
                }
            }
        } else {
            print("✅ Subcollection \(collection)/\(month) exists.")
            completion(true)
        }
    }
}




func saveRemoteMemoryData(userID: String, month: String, weeklyData: [RemoteMemoryData]) {
    let db = Firestore.firestore()
    let monthRef = db.collection("users").document(userID)
        .collection("reports").document("remoteMemory")
        .collection(month)

    print("🚀 Saving remote memory data for \(month)")

    // Calculate summary data
    let totalCorrect = weeklyData.reduce(0) { $0 + $1.correctAnswers }
    let totalIncorrect = weeklyData.reduce(0) { $0 + $1.incorrectAnswers }
    let totalAnswers = totalCorrect + totalIncorrect
    let averageScore = totalAnswers > 0 ? (Double(totalCorrect) / Double(totalAnswers)) * 100 : 0.0

    let summaryRef = monthRef.document("summary")

    // Check if `summary` already exists to preserve `createdAt`
    summaryRef.getDocument { snapshot, _ in
        let existingCreatedAt = snapshot?.data()?["createdAt"] ?? Timestamp()
        
        let summaryData: [String: Any] = [
            "correct": totalCorrect,
            "incorrect": totalIncorrect,
            "averageScore": averageScore,
            "createdAt": existingCreatedAt
        ]

        summaryRef.setData(summaryData, merge: true) { error in
            if let error = error {
                print("❌ Error saving remote memory summary: \(error.localizedDescription)")
            } else {
                print("✅ Remote memory summary saved successfully!")
            }
        }
    }

    // ✅ STEP 2: Save daily data (defaulting to 0 if no data)
    let allDays = (1...31).map { String(format: "%02d", $0) } // Generate "01" to "31"
    let existingDataDict = Dictionary(uniqueKeysWithValues: weeklyData.map { ($0.day, $0) })

    for day in allDays {
        let dayRef = monthRef.document(day)
        
        dayRef.getDocument { snapshot, _ in
            let existingCreatedAt = snapshot?.data()?["createdAt"] ?? Timestamp()
            let memoryData = existingDataDict[day] ?? RemoteMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)

            let dayData: [String: Any] = [
                "correct": memoryData.correctAnswers,
                "incorrect": memoryData.incorrectAnswers,
                "createdAt": existingCreatedAt
            ]

            print("📌 Saving data for \(memoryData.day): \(dayData)")

            dayRef.setData(dayData, merge: true) { error in
                if let error = error {
                    print("❌ Error saving data for \(memoryData.day): \(error.localizedDescription)")
                } else {
                    print("✅ Data saved for \(memoryData.day)")
                }
            }
        }
    }
}










//let mayWeeklyData: [RecentMemoryData] = [
//    RecentMemoryData(day: "Mon", correctAnswers: 18, incorrectAnswers: 2),
//    RecentMemoryData(day: "Tue", correctAnswers: 12, incorrectAnswers: 8),
//    RecentMemoryData(day: "Wed", correctAnswers: 10, incorrectAnswers: 10),
//    RecentMemoryData(day: "Thu", correctAnswers: 14, incorrectAnswers: 6),
//    RecentMemoryData(day: "Fri", correctAnswers: 11, incorrectAnswers: 9),
//    RecentMemoryData(day: "Sat", correctAnswers: 9, incorrectAnswers: 11),
//    RecentMemoryData(day: "Sun", correctAnswers: 14, incorrectAnswers: 6)
//]
//
//let juneWeeklyData: [RecentMemoryData] = [
//    RecentMemoryData(day: "Mon", correctAnswers: 20, incorrectAnswers: 0),
//    RecentMemoryData(day: "Tue", correctAnswers: 15, incorrectAnswers: 5),
//    RecentMemoryData(day: "Wed", correctAnswers: 14, incorrectAnswers: 6),
//    RecentMemoryData(day: "Thu", correctAnswers: 18, incorrectAnswers: 2),
//    RecentMemoryData(day: "Fri", correctAnswers: 16, incorrectAnswers: 4),
//    RecentMemoryData(day: "Sat", correctAnswers: 13, incorrectAnswers: 7),
//    RecentMemoryData(day: "Sun", correctAnswers: 17, incorrectAnswers: 3)
//]
//
//struct MonthlyMemoryData {
//    let month: String
//    let weeklyData: [RecentMemoryData]
//    
//    
//    var monthlyAverageScore: Double {
//        let totalWeeklyScores = weeklyData.reduce(0) { $0 + (Double($1.correctAnswers) / Double($1.correctAnswers + $1.incorrectAnswers)) * 100 }
//        return totalWeeklyScores / Double(weeklyData.count)
//    }
//}
//
//let monthlyMemoryData: [MonthlyMemoryData] = [
//    MonthlyMemoryData(month: "May", weeklyData: mayWeeklyData),
//    MonthlyMemoryData(month: "June", weeklyData: juneWeeklyData)
//]
//
//
//import Foundation
//
//struct MonthlyReport: Identifiable {
//    let id = UUID()
//    let date: Date
//    let correctAnswers: Int
//}
//
//let formatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//    return formatter
//}()
//
//let startDate = formatter.date(from: "2024-11-01")!
//let endDate = formatter.date(from: "2024-11-30")!
//
//func generateFakeMonthlyData(startDate: Date, endDate: Date) -> [MonthlyReport] {
//    var reports: [MonthlyReport] = []
//    var currentDate = startDate
//    
//    while currentDate <= endDate {
//        let randomCorrectAnswers = Int.random(in: 0...20)
//        let report = MonthlyReport(date: currentDate, correctAnswers: randomCorrectAnswers)
//        reports.append(report)
//        
//        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
//    }
//    
//    return reports
//}
//
//let novemberReports = generateFakeMonthlyData(startDate: startDate, endDate: endDate)
