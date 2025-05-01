//
//  CoreAnalyticsService.swift
//  recap
//
//  Created by s1834 on 12/02/25.
//

import Foundation
import FirebaseFirestore

class CoreAnalyticsService {
    private let db = Firestore.firestore()
    private var verifiedUserDocID: String
    
    init?() {
        guard let docID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) else {
            print("❌ Error: verifiedUserDocID not found in UserDefaults.")
            return nil
        }
        self.verifiedUserDocID = docID
    }
    
    private lazy var analyticsRef: DocumentReference? = {
        guard !verifiedUserDocID.isEmpty else { return nil }
        return db.collection("users").document(verifiedUserDocID).collection("core").document("analytics")
    }()
    
    // MARK: - Initialize Analytics
    func initializeAnalytics() {
        let initialData: [String: Any] = [
            "lastFetched": Timestamp(),
            "lastAnswered": Timestamp(date: Date(timeIntervalSince1970: 0)),
            "appInstalled": true,
            "appOpenedFamily": 0,
            "appOpenedPatient": 0,
            "totalSessionsFamily": 0,
            "totalSessionsPatient": 0,
            "totalTimeSpentFamily": 0.0,
            "totalTimeSpentPatient": 0.0,
            "averageUsageTimeFamily": 0.0,
            "averageUsageTimePatient": 0.0,
            "createdAt": Timestamp(),
            "updatedAt": Timestamp()
        ]
        
        updateAnalyticsData(initialData, logFailure: "❌ Firestore Analytics Initialization Failed")
    }
    
    // MARK: - Helper Method for Firestore Updates
    private func updateAnalyticsData(_ data: [String: Any], logFailure: String) {
        analyticsRef?.setData(data, merge: true) { error in
            if let error = error {
                print("\(logFailure): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Track App Open
    func trackAppOpen(isFamily: Bool) {
        let fieldKey = isFamily ? "appOpenedFamily" : "appOpenedPatient"
        
        updateAnalyticsData([
            fieldKey: FieldValue.increment(Int64(1)),
            "updatedAt": Timestamp()
        ], logFailure: "❌ Firestore Update Failed (App Open)")
    }
    
    // MARK: - Track Time Spent
    func trackTimeSpent(sessionDuration: Double, isFamily: Bool) {
        analyticsRef?.getDocument { document, error in
            if let error = error {
                print("❌ Firestore Read Failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = document?.data() else {
                print("❌ Firestore Document is Empty or Nil")
                return
            }

            let totalSessionsKey = isFamily ? "totalSessionsFamily" : "totalSessionsPatient"
            let totalTimeSpentKey = isFamily ? "totalTimeSpentFamily" : "totalTimeSpentPatient"
            let averageUsageTimeKey = isFamily ? "averageUsageTimeFamily" : "averageUsageTimePatient"

            let totalSessions = (data[totalSessionsKey] as? Int ?? 0) + 1
            let totalTimeSpent = (data[totalTimeSpentKey] as? Double ?? 0.0) + sessionDuration
            let averageUsageTime = totalTimeSpent / Double(totalSessions)

            self.updateAnalyticsData([
                totalSessionsKey: totalSessions,
                totalTimeSpentKey: totalTimeSpent,
                averageUsageTimeKey: averageUsageTime,
                "updatedAt": Timestamp()
            ], logFailure: "❌ Error updating time spent")
        }
    }
    
    // MARK: - Track Last Answered
    func trackLastAnswered() {
        updateAnalyticsData([
            "lastAnswered": Timestamp(),
            "updatedAt": Timestamp()
        ], logFailure: "❌ Error updating last answered timestamp")
    }
    
    // MARK: - Track Data Fetched
    func trackDataFetched() {
        updateAnalyticsData([
            "lastFetched": Timestamp(),
            "updatedAt": Timestamp()
        ], logFailure: "❌ Error updating last fetched timestamp")
    }
}
