//
//  DataUpload.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import Foundation

protocol DataUploadProtocol {
    func saveUserDetails(_ details: UserDetails, completion: @escaping (Error?) -> Void)
    func addFamilyMember(for patientId: String, member: FamilyMember, completion: @escaping (Error?) -> Void)
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
}
