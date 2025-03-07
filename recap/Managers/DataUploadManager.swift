//
//  DataUploadManager.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import Foundation

protocol DataUploadProtocol {
    func saveUserDetails(_ details: UserDetails, completion: @escaping (Error?) -> Void)
    func addFamilyMember(for patientId: String, member: FamilyMember, completion: @escaping (Error?) -> Void)
    func uploadMemoryCheckReport(userId: String, reportId: String, data: [String: Any])
}

class DataUploadManager: DataUploadProtocol {
    
    // Saving user details (unchanged)
    func saveUserDetails(_ details: UserDetails, completion: @escaping (Error?) -> Void) {
        FirebaseManager.shared.saveUserDetails(details) { error in
            completion(error)
        }
    }

    // Add family member using Firebase
    func addFamilyMember(for patientId: String, member: FamilyMember, completion: @escaping (Error?) -> Void) {
        FirebaseManager.shared.addFamilyMember(for: patientId, member: member) { error in
            completion(error)
        }
    }
    
    func uploadMemoryCheckReport(userId: String, reportId: String, data: [String: Any]) {
            guard !userId.isEmpty else {
                print("User not logged in.")
                return
            }

            FirebaseManager.shared.uploadDocument(collectionPath: "users/\(userId)/memoryCheckReports", documentId: reportId, data: data) { error in
                if let error = error {
                    print("Failed to upload memory check report: \(error)")
                } else {
                    print("Memory assessment uploaded successfully with ID: \(reportId)")
                }
            }
        }
}
