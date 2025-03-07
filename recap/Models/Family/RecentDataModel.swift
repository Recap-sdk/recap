//
//  RecentDataModel.swift
//  Recap
//
//  Created by admin70 on 29/10/24.
//

import Foundation
import FirebaseFirestore

struct RecentMemoryData: Identifiable {
    let id = UUID()
    let day: String
    let correctAnswers: Int
    let incorrectAnswers: Int
}

class RecentMemoryDataModel: ObservableObject {
    @Published var recentMemoryData: [RecentMemoryData] = []
    @Published var selectedWeekIndex: Int = 0
    var availableWeeks: [(String, [Date])] = []
    
    func fetchWeeks(for verifiedUserDocID: String, selectedMonth: String) {
        let db = Firestore.firestore()
        let recentMemoryRef = db.collection("users").document(verifiedUserDocID).collection("reports").document("recentMemory").collection(selectedMonth)

        recentMemoryRef.getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error checking month existence: \(error.localizedDescription)")
                return
            }

            if snapshot?.documents.isEmpty == true {
                print("⚠️ Month \(selectedMonth) does not exist. Generating weeks and creating month entry.")
                guard let weeks = self.generateWeeks(for: selectedMonth) else { return }
                self.availableWeeks = weeks
                self.createMonthInFirestore(for: verifiedUserDocID, selectedMonth: selectedMonth, weeks: weeks)
            } else {
                print("✅ Month \(selectedMonth) exists, fetching weeks.")
                guard let weeks = self.generateWeeks(for: selectedMonth) else { return }
                self.availableWeeks = weeks
                self.selectedWeekIndex = 0
                self.fetchRecentMemoryData(for: verifiedUserDocID, selectedMonth: selectedMonth)
            }
        }
    }
    
    private func createMonthInFirestore(for verifiedUserDocID: String, selectedMonth: String, weeks: [(String, [Date])]) {
        let db = Firestore.firestore()
        let recentMemoryRef = db.collection("users")
            .document(verifiedUserDocID)
            .collection("reports")
            .document("recentMemory")
            .collection(selectedMonth)

        let batch = db.batch()
        
        let allDaysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let defaultScores: [String: Int] = ["correct": 0, "incorrect": 0]

        for (weekRange, days) in weeks {
            let weekDocRef = recentMemoryRef.document(weekRange)

            var daysDict: [String: [String: Int]] = [:]

            // Initialize all days of the week with default values
            for day in allDaysOfWeek {
                daysDict[day] = defaultScores
            }

            // Override with actual days present in the week
            for date in days {
                let dayName = getWeekdayName(from: date) // Full day name
                daysDict[dayName] = defaultScores // Ensure it exists
            }

            batch.setData(["days": daysDict], forDocument: weekDocRef, merge: true)
        }
        
        batch.commit { error in
            if let error = error {
                print("❌ Error creating month structure: \(error.localizedDescription)")
            } else {
                print("✅ Successfully created month structure for \(selectedMonth)")
                self.selectedWeekIndex = 0
                self.fetchRecentMemoryData(for: verifiedUserDocID, selectedMonth: selectedMonth)
            }
        }
    }
    
    private func generateWeeks(for month: String) -> [(String, [Date])]? {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        guard let startOfMonth = formatter.date(from: month) else { return nil }

        var weeks: [(String, [Date])] = []
        var currentWeek: [Date] = []
        var weekStart: Date?

        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<1
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { continue }
            let weekday = calendar.component(.weekday, from: date)

            if weekday == 1 || day == range.lowerBound {
                if !currentWeek.isEmpty {
                    let weekRange = formatWeekRange(from: currentWeek.first!, to: currentWeek.last!)
                    weeks.append((weekRange, currentWeek))
                }
                currentWeek = []
                weekStart = date
            }

            currentWeek.append(date)
        }

        if !currentWeek.isEmpty, let weekStart = weekStart {
            let weekRange = formatWeekRange(from: weekStart, to: currentWeek.last!)
            weeks.append((weekRange, currentWeek))
        }

        return weeks
    }
    
    private func formatWeekRange(from startDate: Date, to endDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return "\(formatter.string(from: startDate))-\(formatter.string(from: endDate))"
    }

    func fetchRecentMemoryData(for verifiedUserDocID: String, selectedMonth: String) {
        guard !availableWeeks.isEmpty else {
            print("⚠️ No available weeks found for month: \(selectedMonth)")
            return
        }

        let (weekRange, days) = availableWeeks[selectedWeekIndex]
        let allDaysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        var weeklyData = allDaysOfWeek.reduce(into: [String: RecentMemoryData]()) { dict, day in
            dict[day] = RecentMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)
        }

        print("📅 Fetching data for week range: \(weekRange)")

        fetchAndProcessImmediateMemoryData(for: verifiedUserDocID, selectedMonth: selectedMonth, weekRange: weekRange, days: days) { updatedDaysDict, updatedWeeklyData in
            self.recentMemoryData = allDaysOfWeek.map { day in
                updatedWeeklyData[day] ?? RecentMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)
            }

            print("✅ Final processed data: \(self.recentMemoryData)")
        }
    }

    private func fetchAndProcessImmediateMemoryData(for verifiedUserDocID: String, selectedMonth: String, weekRange: String, days: [Date], completion: @escaping ([String: [String: Int]], [String: RecentMemoryData]) -> Void) {
        let db = Firestore.firestore()
        let weekDocRef = db.collection("users").document(verifiedUserDocID).collection("reports")
            .document("recentMemory").collection(selectedMonth).document(weekRange)
        
        let group = DispatchGroup()
        let allDaysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

        let shortToFullDayMap: [String: String] = [
            "Sun": "Sunday", "Mon": "Monday", "Tue": "Tuesday",
            "Wed": "Wednesday", "Thu": "Thursday", "Fri": "Friday", "Sat": "Saturday"
        ]

        var tempDaysDict = allDaysOfWeek.reduce(into: [String: [String: Int]]()) { dict, day in
            dict[day] = ["correct": 0, "incorrect": 0]
        }
        
        var tempWeeklyData = allDaysOfWeek.reduce(into: [String: RecentMemoryData]()) { dict, day in
            dict[day] = RecentMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)
        }

        // Fetch existing week data
        group.enter()
        weekDocRef.getDocument { snapshot, error in
            defer { group.leave() }
            if let error = error {
                print("❌ Error fetching existing week data: \(error.localizedDescription)")
                return
            }

            if let existingData = snapshot?.data()?["days"] as? [String: [String: Int]] {
                print("✅ Existing week data found: \(existingData)")
                for (day, scores) in existingData {
                    let fullDay = shortToFullDayMap[day] ?? day
                    tempDaysDict[fullDay] = scores
                }
            } else {
                print("⚠️ No existing data found for week range: \(weekRange)")
            }

        }

        // Fetch individual daily reports
        for date in days {
            let dateString = formatDate(date)
            let fullDayName = getWeekdayName(from: date)
            let shortDayName = String(fullDayName.prefix(3)) // Get short version (Mon, Tue, etc.)

            let immediateMemoryRef = db.collection("users").document(verifiedUserDocID).collection("reports")
                .document("immediateMemory").collection(dateString).document("summary")

            group.enter()
            immediateMemoryRef.getDocument { snapshot, error in
                defer { group.leave() }

                if let error = error {
                    print("❌ Firestore fetch error on \(dateString): \(error.localizedDescription)")
                    return
                }

                let data = snapshot?.data()
                let correctAnswers = data?["correctAnswers"] as? Int ?? 0
                let incorrectAnswers = data?["incorrectAnswers"] as? Int ?? 0

                print("📊 Data for \(fullDayName) (\(dateString)) - Correct: \(correctAnswers), Incorrect: \(incorrectAnswers)")

                if correctAnswers != 0 || incorrectAnswers != 0 {
                    tempDaysDict[fullDayName] = ["correct": correctAnswers, "incorrect": incorrectAnswers]
                    tempWeeklyData[fullDayName] = RecentMemoryData(day: fullDayName, correctAnswers: correctAnswers, incorrectAnswers: incorrectAnswers)
                }
            }
        }

        group.notify(queue: .main) {
            // ✅ Ensure only full day names are stored
            let filteredDaysDict = tempDaysDict.filter { allDaysOfWeek.contains($0.key) }

            self.recentMemoryData = allDaysOfWeek.map { day in
                tempWeeklyData[day] ?? RecentMemoryData(day: day, correctAnswers: 0, incorrectAnswers: 0)
            }
            print("✅ Final processed data: \(self.recentMemoryData)")

            self.updateFirestoreWithProcessedData(for: verifiedUserDocID, selectedMonth: selectedMonth, weekRange: weekRange, daysDict: filteredDaysDict)
        }
    }

    private func updateFirestoreWithProcessedData(for verifiedUserDocID: String, selectedMonth: String, weekRange: String, daysDict: [String: [String: Int]]) {
        let db = Firestore.firestore()
        let weekDocRef = db.collection("users")
            .document(verifiedUserDocID)
            .collection("reports")
            .document("recentMemory")
            .collection(selectedMonth)
            .document(weekRange)

        weekDocRef.setData(["days": daysDict], merge: true) { error in
            if let error = error {
                print("❌ Error updating Firestore with processed data: \(error.localizedDescription)")
            } else {
                print("✅ Successfully updated Firestore with final processed data.")
            }
        }
    }



    func goToNextWeek(for verifiedUserDocID: String, selectedMonth: String) {
        if selectedWeekIndex < availableWeeks.count - 1 {
            selectedWeekIndex += 1
            fetchRecentMemoryData(for: verifiedUserDocID, selectedMonth: selectedMonth)
        }
    }

    func goToPreviousWeek(for verifiedUserDocID: String, selectedMonth: String) {
        if selectedWeekIndex > 0 {
            selectedWeekIndex -= 1
            fetchRecentMemoryData(for: verifiedUserDocID, selectedMonth: selectedMonth)
        }
    }

  
    
    


    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func getWeekdayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // Full day name (Sunday, Monday, etc.)
        return formatter.string(from: date)
    }
}
