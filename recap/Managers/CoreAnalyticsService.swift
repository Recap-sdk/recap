//
//  CoreAnalyticsService.swift
//  recap
//
//  Created by user@47 on 12/02/25.
//

import Foundation
import FirebaseFirestore

class CoreAnalyticsService {
    
    private let db = Firestore.firestore()
    private var verifiedUserDocID: String
    
    init(verifiedUserDocID: String) {
        self.verifiedUserDocID = verifiedUserDocID
        print("✅ CoreAnalyticsService initialized with User Doc ID: \(verifiedUserDocID)")
    }
    
    private var analyticsRef: DocumentReference {
        return db.collection("users").document(verifiedUserDocID).collection("core").document("analytics")
    }

    /// Initializes the analytics document, ensuring the 'core' subcollection exists
    func initializeAnalytics() {
        analyticsRef.setData([
            "lastFetched": Timestamp(date: Date()),
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
            "createdAt": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ], merge: true) { error in
            if let error = error {
                print("❌ Firestore Analytics Initialization Failed: \(error.localizedDescription)")
            } else {
                print("✅ Firestore Analytics Initialized Successfully")
            }
        }
    }
    
    /// Tracks the number of times the app has been opened (by family or patient)
    func trackAppOpen(isFamily: Bool) {
        let fieldKey = isFamily ? "appOpenedFamily" : "appOpenedPatient"
        
        analyticsRef.updateData([
            fieldKey: FieldValue.increment(Int64(1)),
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Firestore Update Failed (App Open): \(error.localizedDescription)")
            } else {
                print("✅ Firestore Update Success (App Open) - \(fieldKey)")
            }
        }
    }
    
    /// Tracks the session time spent by family or patient
    func trackTimeSpent(sessionDuration: Double, isFamily: Bool) {
        analyticsRef.getDocument { document, error in
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

            self.analyticsRef.updateData([
                totalSessionsKey: totalSessions,
                totalTimeSpentKey: totalTimeSpent,
                averageUsageTimeKey: averageUsageTime,
                "updatedAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    print("❌ Error updating time spent: \(error.localizedDescription)")
                } else {
                    print("✅ Time spent updated successfully for \(isFamily ? "Family" : "Patient")")
                }
            }
        }
    }
    
    /// Tracks the last time a patient answered a question
    func trackLastAnswered() {
        analyticsRef.updateData([
            "lastAnswered": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Error updating last answered timestamp: \(error.localizedDescription)")
            } else {
                print("✅ Last answered timestamp updated.")
            }
        }
    }
    
    /// Tracks when data was last fetched
    func trackDataFetched() {
        analyticsRef.updateData([
            "lastFetched": Timestamp(date: Date()),
            "updatedAt": Timestamp(date: Date())
        ]) { error in
            if let error = error {
                print("❌ Error updating last fetched timestamp: \(error.localizedDescription)")
            } else {
                print("✅ Last fetched timestamp updated.")
            }
        }
    }
}
