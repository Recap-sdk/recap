//
//  DataFetchmanager.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import Foundation
import FirebaseFirestore

protocol DataFetchProtocol {
    func fetchRapidQuestions(completion: @escaping ([rapiMemory]?, Error?) -> Void)
    func fetchUserProfile(userId: String, completion: @escaping ([String: Any]?, Error?) -> Void)
    func fetchFamilyMembers(userId: String, completion: @escaping ([FamilyMember]?, Error?) -> Void)
}

class DataFetch: DataFetchProtocol {
    private let firestore = Firestore.firestore()

    // Fetch rapid questions
    func fetchRapidQuestions(completion: @escaping ([rapiMemory]?, Error?) -> Void) {
        FirebaseManager.shared.fetchData(DBName: "rapidMemoryQuestions") { (data: [rapiMemory]?, error) in
            completion(data, error)
        }
    }

    // Fetch user profile
    func fetchUserProfile(userId: String, completion: @escaping ([String: Any]?, Error?) -> Void) {
        firestore.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            guard let data = document?.data() else {
                completion(nil, NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            completion(data, nil)
        }
    }

    // Fetch family members
    func fetchFamilyMembers(userId: String, completion: @escaping ([FamilyMember]?, Error?) -> Void) {
        firestore.collection("users").document(userId).collection("family_members").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching family members: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            let familyMembers = snapshot?.documents.compactMap { doc -> FamilyMember? in
                let data = doc.data()
                return FamilyMember(
                    id: UUID(uuidString: doc.documentID) ?? UUID(),
                    name: data["name"] as? String ?? "",
                    relationship: data["relationship"] as? String ?? "",
                    phone: data["phone"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    password: data["password"] as? String ?? "",
                    imageName: data["imageName"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? ""
                )
            }
            completion(familyMembers, nil)
        }
    }
}
