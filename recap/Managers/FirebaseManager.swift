//
//  FirebaseManager.swift
//  recap
//
//  Created by Diptayan Jash on 14/12/24.
//

import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import Foundation

class FirebaseManager {
    static let shared = FirebaseManager()
    private let databaseRef = Database.database().reference()
    private let storage = Storage.storage().reference()
    let firestore = Firestore.firestore() // Initialize Firestore

    func fetchData<T: FireBaseDecodable>(DBName: String, completion: @escaping ([T]?, Error?) -> Void) {
        let databaseReference = databaseRef.child(DBName)
        databaseReference.observeSingleEvent(of: .value, with: { snapshot in
            print("Firebase raw data:", snapshot.value ?? "no data")

            if let dict = snapshot.value as? [String: Any] {
                let items = [T(id: dict["id"] as? String ?? UUID().uuidString, fireData: dict)]
                completion(items, nil)
            } else if let dataList = snapshot.value as? [[String: Any]?] {
                let data: [T] = dataList.compactMap { dict in
                    guard let dict = dict else { return nil }
                    return T(id: dict["id"] as? String ?? UUID().uuidString, fireData: dict)
                }
                completion(data, nil)
            } else {
                completion(nil, NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]))
            }
        }) { error in
            completion(nil, error)
        }
    }

//    func saveUserDetails(_ details: UserDetails, completion: @escaping (Error?) -> Void) {
//        let userId = details.id
//        firestore.collection("users").document(userId).setData(details.dictionary) { error in
//            completion(error)
//        }
//    }
    func uploadFamilyMemberImage(patientId: String, imagePath: String, image: UIImage, completion: @escaping (String?, Error?) -> Void) {
        let storageRef = storage.child(imagePath)

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil, NSError(domain: "ImageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."]))
            return
        }

        // Upload image to Firebase Storage
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(nil, error)
                return
            }

            // Get download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    guard let imageUrl = url?.absoluteString else {
                        completion(nil, NSError(domain: "ImageError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                        return
                    }
                    completion(imageUrl, nil)  // Return image URL immediately

                    // Trigger Firestore update after image upload
                    let firestoreRef = self.firestore.collection(Constants.FirestoreKeys.usersCollection)
                        .document(patientId)
                        .collection(Constants.FirestoreKeys.familyMembersCollection)
                        .document(imagePath)

                    firestoreRef.updateData(["imageURL": imageUrl]) { error in
                        if let error = error {
                            print("Failed to update Firestore document with image URL: \(error)")
                        } else {
                            print("Firestore document updated successfully with image URL")
                        }
                    }
                }
            }
        }
    }
    
    func saveUserDetails(_ details: UserDetails, completion: @escaping (Error?) -> Void) {
        let userId = details.id
        let userData: [String: Any] = [
            "email": details.email,
            "type": "patient",
            "firstName": details.firstName,
            "lastName": details.lastName,
            "dateOfBirth": details.dateOfBirth,
            "sex": details.sex,
            "bloodGroup": details.bloodGroup,
            "stage": details.stage,
            "profileImageURL": details.profileImageURL ?? "",
        ]

        firestore.collection("users").document(userId).setData(userData) { error in
            completion(error)
        }
    }

//    func addFamilyMember(for patientId: String, member: FamilyMember, completion: @escaping (Error?) -> Void) {
//        let familyMemberData = member.dictionary
//        firestore.collection("users").document(patientId).collection("familyMembers").addDocument(data: familyMemberData) { error in
//            completion(error)
//        }
//    }

    func addFamilyMember(for patientId: String, member: FamilyMember, completion: @escaping (Error?) -> Void) {
        let familyMemberData: [String: Any] = [
            "name": member.name,
            "email": member.email,
            "password": member.password, // Store password securely
            "relationship": member.relationship,
            "phone": member.phone,
            "linkedPatientId": patientId, // Link the family member to the patient
            "imageName": member.imageName,
            "imageURL": member.imageURL,
        ]
        firestore
            .collection(Constants.FirestoreKeys.usersCollection)
            .document(patientId)
            .collection(Constants.FirestoreKeys.familyMembersCollection)
            .addDocument(data: familyMemberData) { error in
                completion(error)
            }
    }

    func fetchUserDetails(userId: String, completion: @escaping (UserDetails?, Error?) -> Void) {
        firestore.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = document, document.exists,
                  let data = document.data() else {
                completion(nil, NSError(domain: "FirebaseError", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }

            let userDetails = UserDetails(id: userId, fireData: data)
            completion(userDetails, nil)
        }
    }

    func fetchUserProfile(userId: String, completion: @escaping ([String: Any]?) -> Void) {
        firestore.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error fetching user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = document?.data() else {
                completion(nil)
                return
            }

            completion(data)
        }
    }

    func deleteFamilyMember(for patientId: String, memberId: String, completion: @escaping (Error?) -> Void) {
        firestore
            .collection(Constants.FirestoreKeys.usersCollection)
            .document(patientId)
            .collection(Constants.FirestoreKeys.familyMembersCollection)
            .document(memberId)
            .delete { error in
                if let error = error {
                    print("Error deleting family member from Firebase: \(error.localizedDescription)")
                } else {
                    print("Successfully deleted family member \(memberId)")
                }
                completion(error)
            }
    }

    func fetchFamilyMembers(for patientId: String, completion: @escaping ([FamilyMember]?, Error?) -> Void) {
        firestore
            .collection(Constants.FirestoreKeys.usersCollection)
            .document(patientId)
            .collection(Constants.FirestoreKeys.familyMembersCollection)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                let familyMembers = snapshot?.documents.compactMap { doc -> FamilyMember? in
                    let data = doc.data()
                    return FamilyMember(
                        id: doc.documentID, // Use the actual Firestore document ID
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

    func uploadDocument(collectionPath: String, documentId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        firestore.collection(collectionPath).document(documentId).setData(data) { error in
            completion(error)
        }
    }
}
