//
//  StreakService.swift
//  recap
//
//  Created by user@47 on 06/02/25.
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
        self.verifiedUserDocID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID)!
        print("✅ StreakService initialized with User Doc ID: \(verifiedUserDocID)")
    }
    
    func updateStreak(for day: Int, with value: Bool) {
        let date = getFormattedDate(for: day)
        let yearMonth = date.prefix(7) // YYYY-MM
        
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(String(yearMonth))
        
        streakDocRef.updateData([
            date: value
        ]) { error in
            if let error = error {
                print("Error updating streak: \(error.localizedDescription)")
            } else {
                print("Streak updated successfully")
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
        let today = getFormattedDateForToday()  // Use this function to get today's date
        let yearMonth = today.prefix(7) // YYYY-MM
        
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(String(yearMonth))
        
        // Use setData with merge: true to ensure the data gets added or updated for today's date
        streakDocRef.setData([today: value], merge: true) { error in
            if let error = error {
                print("Error updating streak for today: \(error.localizedDescription)")
            } else {
                print("Streak updated successfully for today: \(today)")
            }
        }
    }
    
    // Function to return today's date
    private func getFormattedDateForToday() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = Date() // This will always return today's date
        return formatter.string(from: today)
    }
    
    
    func getStreaksForUser(yearMonth: String, completion: @escaping (Streak?) -> Void) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.getDocument { (document, error) in
            if let error = error {
                print("❌ Error getting streaks: \(error.localizedDescription)")
                completion(nil)
            } else if let document = document, document.exists {
                print("✅ Successfully fetched streaks for \(yearMonth)")
                
                if let streakData = document.data() as? [String: Bool] {
                    let streak = Streak(streakDates: streakData)
                    completion(streak)
                } else {
                    print("⚠️ No valid streak data found.")
                    completion(nil)
                }
            } else {
                print("⚠️ No streak document found for \(yearMonth)")
                completion(nil)
            }
        }
    }
    
    func updateStreak(yearMonth: String, date: String, isStreakCompleted: Bool) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.updateData([date: isStreakCompleted]) { error in
            if let error = error {
                print("Error updating streak: \(error.localizedDescription)")
            } else {
                print("Streak updated successfully.")
            }
        }
    }
    
    //    private func ensureStreaksCoreExists(completion: @escaping () -> Void) {
    //           guard let verifiedUserDocID = verifiedUserDocID else {
    //               print("Error: No verified user ID found.")
    //               return
    //           }
    //
    //           let coreRef = db.collection("users").document(verifiedUserDocID).collection("streaksCore").document("streakData")
    //
    //           coreRef.getDocument { document, error in
    //               if let error = error {
    //                   print("Error checking streaksCore existence: \(error.localizedDescription)")
    //                   return
    //               }
    //
    //               if document?.exists == true {
    //                   completion() // Continue with the update
    //               } else {
    //                   // Create the initial structure
    //                   coreRef.setData(["initialized": true], merge: true) { error in
    //                       if let error = error {
    //                           print("Error creating streaksCore: \(error.localizedDescription)")
    //                       } else {
    //                           print("streaksCore initialized")
    //                           completion()
    //                       }
    //                   }
    //               }
    //           }
    //       }
    
    
    func createOrUpdateMonthlyStreak(yearMonth: String, streak: Streak) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.setData(streak.streakDates) { error in
            if let error = error {
                print("Error updating monthly streak: \(error.localizedDescription)")
            } else {
                print("Monthly streak successfully updated.")
            }
        }
    }
    
    func updateStreaksForUser(streaks: [String: Bool], completion: @escaping (Bool) -> Void) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(getCurrentYearMonth())
        
        guard !streaks.isEmpty else {
            print("Error: Streaks data is empty.")
            completion(false)
            return
        }
        
        streakDocRef.setData(streaks) { error in
            if let error = error {
                print("Error uploading streaks: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func getCurrentYearMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return dateFormatter.string(from: Date())
        //        return "2025-02"
    }
    
    func fetchAndPrintStreakData() {
        ensureStreaksCoreExists {
            let coreRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaksCore")

            coreRef.getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching streak data: \(error.localizedDescription)")
                    return
                }

                if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                    for document in querySnapshot.documents {
                        let data = document.data()

                        let maxStreak = data["maxStreak"] as? Int ?? 0
                        let currentStreak = data["currentStreak"] as? Int ?? 0
                        let activeDays = data["activeDays"] as? Int ?? 0
                        let answeredToday = data["answeredToday"] as? Bool ?? false
                        let lastAnsweredDate = (data["lastAnsweredDate"] as? Timestamp)?.dateValue() ?? Date.distantPast
                        let totalQuestionsAnswered = data["totalQuestionsAnswered"] as? Int ?? 0
                        let correctAnswers = data["correctAnswers"] as? Int ?? 0
                        let longestBreak = data["longestBreak"] as? Int ?? 0

                        print("Max Streak: \(maxStreak)")
                        print("Current Streak: \(currentStreak)")
                        print("Active Days: \(activeDays)")

                        // Call the closure to update the UI
                        self.streakDataFetched?(maxStreak, currentStreak, activeDays)

                        // Call method to calculate streak stats
                        self.calculateStreakStats(
                            maxStreak: maxStreak,
                            answeredToday: answeredToday,
                            currentStreak: currentStreak,
                            activeDays: activeDays,
                            lastAnsweredDate: lastAnsweredDate,
                            totalQuestionsAnswered: totalQuestionsAnswered,
                            correctAnswers: correctAnswers,
                            longestBreak: longestBreak
                        )
                    }
                } else {
                    print("No streak data found.")
                }
            }
        }
    }
    
    // Calculate streak stats
    //       func calculateStreakStats(
    //           maxStreak: Int,
    //           answeredToday: Bool,
    //           currentStreak: Int,
    //           activeDays: Int,
    //           lastAnsweredDate: Date,
    //           totalQuestionsAnswered: Int,
    //           correctAnswers: Int,
    //           longestBreak: Int
    //       ) {
    //           let calendar = Calendar.current
    //           let today = Date()
    //
    //           var newCurrentStreak = currentStreak
    //           var newMaxStreak = maxStreak
    //           var newActiveDays = activeDays
    //           var newAnsweredToday = answeredToday
    //           var newLongestBreak = longestBreak
    //           var newTotalQuestionsAnswered = totalQuestionsAnswered + 1  // Increment count
    //           var newCorrectAnswers = correctAnswers // Increment based on correctness (handled later)
    //
    //           let daysSinceLastAnswer = calendar.dateComponents([.day], from: lastAnsweredDate, to: today).day ?? 0
    //
    //           if calendar.isDateInToday(lastAnsweredDate) {
    //               newAnsweredToday = true
    //           } else if daysSinceLastAnswer == 1 {
    //               newCurrentStreak += 1
    //               newAnsweredToday = true
    //           } else {
    //               newCurrentStreak = 1
    //               newAnsweredToday = false
    //               newLongestBreak = max(newLongestBreak, daysSinceLastAnswer) // Track longest break
    //           }
    //
    //           newMaxStreak = max(newMaxStreak, newCurrentStreak)
    //
    //           if !calendar.isDate(lastAnsweredDate, inSameDayAs: today) {
    //               newActiveDays += 1
    //           }
    //
    //           // Update streak data after calculation
    //           self.updateStreakData(
    //               maxStreak: newMaxStreak,
    //               answeredToday: newAnsweredToday,
    //               currentStreak: newCurrentStreak,
    //               activeDays: newActiveDays,
    //               totalQuestionsAnswered: newTotalQuestionsAnswered,
    //               correctAnswers: newCorrectAnswers,
    //               longestBreak: newLongestBreak
    //           )
    //       }
    //
    //       // Update streak data in Firestore
    //       func updateStreakData(
    //           maxStreak: Int,
    //           answeredToday: Bool,
    //           currentStreak: Int,
    //           activeDays: Int,
    //           totalQuestionsAnswered: Int,
    //           correctAnswers: Int,
    //           longestBreak: Int
    //       ) {
    //           let coreRef = db.collection("users").document(verifiedUserDocID).collection("core").document("streakData")
    //
    //           coreRef.setData([
    //               "maxStreak": maxStreak,
    //               "answeredToday": answeredToday,
    //               "currentStreak": currentStreak,
    //               "activeDays": activeDays,
    //               "totalQuestionsAnswered": totalQuestionsAnswered,
    //               "correctAnswers": correctAnswers,
    //               "longestBreak": longestBreak,
    //               "lastAnsweredDate": Timestamp(date: Date())
    //           ], merge: true) { error in
    //               if let error = error {
    //                   print("Error updating streak data: \(error.localizedDescription)")
    //               } else {
    //                   print("Streak data successfully updated")
    //               }
    //           }
    //       }
    
    
    
    private func ensureStreaksCoreExists(completion: @escaping () -> Void) {
        let coreRef = db.collection("users").document(verifiedUserDocID).collection("streaksCore").document("streakData")
        
        coreRef.getDocument { document, error in
            if let error = error {
                print("Error checking streaksCore existence: \(error.localizedDescription)")
                return
            }
            
            if document?.exists == true {
                completion() // Continue with the update
            } else {
                // Create the initial structure
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
    
    func calculateStreakStats(
        maxStreak: Int,
        answeredToday: Bool,
        currentStreak: Int,
        activeDays: Int,
        lastAnsweredDate: Date,
        totalQuestionsAnswered: Int,
        correctAnswers: Int,
        longestBreak: Int
    ) {
        let calendar = Calendar.current
        let today = Date()
        
        var newCurrentStreak = currentStreak
        var newMaxStreak = maxStreak
        var newActiveDays = activeDays
        var newAnsweredToday = answeredToday
        var newLongestBreak = longestBreak
        var newTotalQuestionsAnswered = totalQuestionsAnswered + 1  // Increment count
        var newCorrectAnswers = correctAnswers // Increment based on correctness (handled later)
        
        let daysSinceLastAnswer = calendar.dateComponents([.day], from: lastAnsweredDate, to: today).day ?? 0
        
        if calendar.isDateInToday(lastAnsweredDate) {
            newAnsweredToday = true
        } else if daysSinceLastAnswer == 1 {
            newCurrentStreak += 1
            newAnsweredToday = true
        } else {
            newCurrentStreak = 1
            newAnsweredToday = false
            newLongestBreak = max(newLongestBreak, daysSinceLastAnswer) // Track longest break
        }
        
        newMaxStreak = max(newMaxStreak, newCurrentStreak)
        
        if !calendar.isDate(lastAnsweredDate, inSameDayAs: today) {
            newActiveDays += 1
        }
        
        updateStreakData(
            maxStreak: newMaxStreak,
            answeredToday: newAnsweredToday,
            currentStreak: newCurrentStreak,
            activeDays: newActiveDays,
            totalQuestionsAnswered: newTotalQuestionsAnswered,
            correctAnswers: newCorrectAnswers,
            longestBreak: newLongestBreak
        )
    }
    
    
    func updateStreakData(
        maxStreak: Int,
        answeredToday: Bool,
        currentStreak: Int,
        activeDays: Int,
        totalQuestionsAnswered: Int,
        correctAnswers: Int,
        longestBreak: Int
    ) {
        ensureStreaksCoreExists {
            let coreRef = self.db.collection("users").document(self.verifiedUserDocID).collection("streaksCore").document("streakData")
            
            coreRef.setData([
                "maxStreak": maxStreak,
                "answeredToday": answeredToday,
                "currentStreak": currentStreak,
                "activeDays": activeDays,
                "totalQuestionsAnswered": totalQuestionsAnswered,
                "correctAnswers": correctAnswers,
                "longestBreak": longestBreak,
                "lastAnsweredDate": Timestamp(date: Date())
            ], merge: true) { error in
                if let error = error {
                    print("Error updating streak data: \(error.localizedDescription)")
                } else {
                    print("Streak data successfully updated")
                }
            }
        }
    }
}
