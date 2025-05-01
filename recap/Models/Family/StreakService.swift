//
//  StreakService.swift
//  recap
//
//  Created by s1834 on 06/02/25.
//

import Foundation
import FirebaseFirestore

struct Streak: Codable {
    var streakDates: [String: Bool]
}

class StreakService {
    
    private let db = Firestore.firestore()
    private let verifiedUserDocID: String
    
    var streakDataFetched: ((Int, Int, Int) -> Void)?
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
    }
    
    func ensureCurrentMonthExists(completion: @escaping () -> Void) {
        let yearMonth = getCurrentYearMonth()
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking streak document: \(error.localizedDescription)")
                return
            }
            
            if document?.exists == true {
                completion()
            } else {
                self.createMonthStreakDocument(yearMonth: yearMonth, completion: completion)
            }
        }
    }
    
    private func getCurrentYearMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.string(from: Date())
    }
    
    private func createMonthStreakDocument(yearMonth: String, completion: @escaping () -> Void) {
        let totalDays = getDaysInMonth(yearMonth: yearMonth)
        let streakData = (1...totalDays).reduce(into: [String: Bool]()) { dict, day in
            dict["\(yearMonth)-\(String(format: "%02d", day))"] = false
        }
        
        db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth).setData(streakData) { error in
            if let error = error {
                print("❌❌ Error creating monthly streak document: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    private func getDaysInMonth(yearMonth: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        guard let date = dateFormatter.date(from: yearMonth) else { return 30 }
        
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 30
    }
    
    func updateStreak(for day: Int, with value: Bool) {
        ensureCurrentMonthExists {
            let date = self.getFormattedDate(for: day)
            let yearMonth = date.prefix(7)
            
            let streakDocRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaks").document(String(yearMonth))
                
            streakDocRef.updateData([
                date: value
            ]) { error in
                if let error = error {
                    print("❌❌ Error updating streak: \(error.localizedDescription)")
                }
            }
        }
    }
        
    private func getFormattedDate(for day: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: day, to: today)!
        return formatter.string(from: date)
    }
    
    func updateStreakForToday(with value: Bool) {
        ensureCurrentMonthExists {
            let today = self.getFormattedDateForToday()
            let yearMonth = today.prefix(7)
            
            let streakDocRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaks").document(String(yearMonth))
                
            streakDocRef.setData([today: value], merge: true) { error in
                if let error = error {
                    print("❌❌ Error updating streak for today: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func getFormattedDateForToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date()
        return formatter.string(from: today)
    }
    
    func getStreaksForUser(yearMonth: String, completion: @escaping (Streak?) -> Void) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.getDocument { (document, error) in
            if let error = error {
                print("❌❌ Error getting streaks: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                if let streakData = document.data() as? [String: Bool] {
                    let streak = Streak(streakDates: streakData)
                    completion(streak)
                } else {
                    print("⚠️⚠️ No valid streak data found.")
                    completion(nil)
                }
            } else {
                print("⚠️⚠️ No streak document found for \(yearMonth)")
                completion(nil)
            }
        }
    }

    func fetchAndUpdateStreakStats() {
        ensureStreaksCoreExists {
            let coreRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaksCore").document("streakData")

            coreRef.getDocument { document, error in
                if let error = error {
                    print("Error fetching streak data: \(error.localizedDescription)")
                    return
                }

                if let document = document, let data = document.data() {
                    let maxStreak = data["maxStreak"] as? Int ?? 0
                    let currentStreak = data["currentStreak"] as? Int ?? 0
                    let activeDays = data["activeDays"] as? Int ?? 0
                    let answeredToday = data["answeredToday"] as? Bool ?? false
                    let lastAnsweredDate = (data["lastAnsweredDate"] as? Timestamp)?.dateValue() ?? Date.distantPast
                    let totalQuestionsAnswered = data["totalQuestionsAnswered"] as? Int ?? 0
                    let correctAnswers = data["correctAnswers"] as? Int ?? 0
                    let longestBreak = data["longestBreak"] as? Int ?? 0

                    self.streakDataFetched?(maxStreak, currentStreak, activeDays)

                    self.calculateStreakStats(maxStreak: maxStreak, answeredToday: answeredToday, currentStreak: currentStreak, activeDays: activeDays, lastAnsweredDate: lastAnsweredDate, totalQuestionsAnswered: totalQuestionsAnswered, correctAnswers: correctAnswers, longestBreak: longestBreak)
                }
            }
        }
    }

    private func ensureStreaksCoreExists(completion: @escaping () -> Void) {
        let coreRef = db.collection("users").document(verifiedUserDocID).collection("streaksCore").document("streakData")
        
        coreRef.getDocument { document, error in
            if let error = error {
                print("Error checking streaksCore existence: \(error.localizedDescription)")
                return
            }
            
            if document?.exists == true {
                completion()
            } else {
                coreRef.setData(["initialized": true], merge: true) { error in
                    if let error = error {
                        print("Error creating streaksCore: \(error.localizedDescription)")
                    } else {
                        print("streaksCore initialized")
                        completion()
                    }
                }
            }
        }
    }
    
    func calculateStreakStats(maxStreak: Int, answeredToday: Bool, currentStreak: Int, activeDays: Int, lastAnsweredDate: Date, totalQuestionsAnswered: Int, correctAnswers: Int, longestBreak: Int) {
        let calendar = Calendar.current
        let today = Date()
        
        var newCurrentStreak = currentStreak
        var newMaxStreak = maxStreak
        var newActiveDays = activeDays
        var newAnsweredToday = answeredToday
        var newLongestBreak = longestBreak
        var newTotalQuestionsAnswered = totalQuestionsAnswered + 1
        var newCorrectAnswers = correctAnswers
        
        let daysSinceLastAnswer = calendar.dateComponents([.day], from: lastAnsweredDate, to: today).day ?? 0
        
        if calendar.isDateInToday(lastAnsweredDate) {
            newAnsweredToday = true
        } else if daysSinceLastAnswer == 1 {
            newCurrentStreak += 1
            newActiveDays += 1
            newAnsweredToday = true
        } else {
            newCurrentStreak = currentStreak
            newAnsweredToday = false
            newLongestBreak = max(newLongestBreak, daysSinceLastAnswer)
        }
        
        newMaxStreak = max(newMaxStreak, newCurrentStreak)
        
        updateStreakData(maxStreak: newMaxStreak, answeredToday: newAnsweredToday, currentStreak: newCurrentStreak, activeDays: newActiveDays, totalQuestionsAnswered: newTotalQuestionsAnswered, correctAnswers: newCorrectAnswers, longestBreak: newLongestBreak)
    }
    
    
    func updateStreakData(maxStreak: Int, answeredToday: Bool, currentStreak: Int, activeDays: Int, totalQuestionsAnswered: Int, correctAnswers: Int, longestBreak: Int) {
        ensureStreaksCoreExists {
            let coreRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaksCore").document("streakData")
            
            coreRef.setData(["maxStreak": maxStreak, "answeredToday": answeredToday, "currentStreak": currentStreak, "activeDays": activeDays, "totalQuestionsAnswered": totalQuestionsAnswered, "correctAnswers": correctAnswers, "longestBreak": longestBreak, "lastAnsweredDate": Timestamp(date: Date())], merge: true) { error in
                if let error = error {
                    print("Error updating streak data: \(error.localizedDescription)")
                }
            }
        }
    }
}
