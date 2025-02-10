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
    private var verifiedUserDocID: String

    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
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

    func ensureStreakDocumentExists(yearMonth: String) {
        let streakDocRef = db.collection("users").document(verifiedUserDocID).collection("streaks").document(yearMonth)
        
        streakDocRef.getDocument { (document, error) in
            if let error = error {
                print("Error checking streak document: \(error.localizedDescription)")
                return
            }
            
            if document == nil {
                streakDocRef.setData([:]) { error in
                    if let error = error {
                        print("Error creating streak document: \(error.localizedDescription)")
                    } else {
                        print("Streak document created successfully.")
                    }
                }
            }
        }
    }

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
}
