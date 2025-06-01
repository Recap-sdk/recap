//
//  AccountDeletionManager.swift
//  recap
//
//  Created on 31/05/25.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import UIKit

class AccountDeletionManager {
    static let shared = AccountDeletionManager()

    private init() {}

    // MARK: - Delete Patient Account
    func deletePatientAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let user = Auth.auth().currentUser, let userId = Auth.auth().currentUser?.uid else {
            completion(
                false,
                NSError(
                    domain: "AccountDeletion", code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "No user is currently signed in"]))
            return
        }

        let db = Firestore.firestore()

        // 1. Delete all user data from Firestore
        let userDocRef = db.collection("users").document(userId)

        // 2. Get references to all subcollections to delete
        userDocRef.getDocument { document, error in
            if let error = error {
                completion(false, error)
                return
            }

            let dispatchGroup = DispatchGroup()

            // 3. Delete family members subcollection
            dispatchGroup.enter()
            self.deleteCollection(db: db, collectionPath: "users/\(userId)/family_members") {
                success, error in
                if let error = error {
                    print("Error deleting family_members collection: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }

            // 4. Delete memory checks subcollection
            dispatchGroup.enter()
            self.deleteCollection(db: db, collectionPath: "users/\(userId)/memory_checks") {
                success, error in
                if let error = error {
                    print("Error deleting memory_checks collection: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }

            // 5. Delete any other subcollections here
            // ...

            // 6. Wait for all subcollection deletions to complete
            dispatchGroup.notify(queue: .main) {
                // 7. Delete the main user document
                userDocRef.delete { error in
                    if let error = error {
                        print("Error deleting user document: \(error.localizedDescription)")
                    }

                    // 8. Finally, delete the Firebase Auth user
                    user.delete { error in
                        if let error = error {
                            completion(false, error)
                        } else {
                            // 9. Clear local data
                            self.clearLocalUserData()
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Delete Family Member Account
    func deleteFamilyMemberAccount(completion: @escaping (Bool, Error?) -> Void) {
        // Get family member and patient information
        guard
            let familyMemberDetails = UserDefaults.standard.dictionary(
                forKey: Constants.UserDefaultsKeys.familyMemberDetails),
            let familyMemberId = familyMemberDetails["id"] as? String,
            let patientId = UserDefaults.standard.string(forKey: "verifiedUserDocID")
        else {
            completion(
                false,
                NSError(
                    domain: "AccountDeletion", code: 402,
                    userInfo: [NSLocalizedDescriptionKey: "Family member data not found"]))
            return
        }

        let db = Firestore.firestore()

        // Delete family member document from Firestore
        db.collection("users").document(patientId).collection("family_members").document(
            familyMemberId
        ).delete { error in
            if let error = error {
                completion(false, error)
                return
            }

            // Clear local data
            self.clearLocalFamilyMemberData()
            completion(true, nil)
        }
    }

    // MARK: - Helper Methods
    private func deleteCollection(
        db: Firestore, collectionPath: String, completion: @escaping (Bool, Error?) -> Void
    ) {
        db.collection(collectionPath).getDocuments { snapshot, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard let snapshot = snapshot else {
                completion(true, nil)
                return
            }

            guard !snapshot.documents.isEmpty else {
                completion(true, nil)
                return
            }

            let dispatchGroup = DispatchGroup()

            for document in snapshot.documents {
                dispatchGroup.enter()
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting document \(document.documentID): \(error)")
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(true, nil)
            }
        }
    }

    private func clearLocalUserData() {
        // Clear all user-related data from UserDefaults
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.verifiedUserDocID)
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.synchronize()

        // Clear profile data
        UserDefaultsStorageProfile.shared.clearProfile()
    }

    private func clearLocalFamilyMemberData() {
        // Clear family member data from UserDefaults
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.familyMemberDetails)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.familyMemberImageURL)
        UserDefaults.standard.removeObject(
            forKey: Constants.UserDefaultsKeys.isFamilyMemberLoggedIn)
        UserDefaults.standard.removeObject(forKey: "verifiedUserDocID")
        UserDefaults.standard.synchronize()
    }
}
