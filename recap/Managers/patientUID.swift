//
//  patientUID.swift
//  recap
//
//  Created by Diptayan Jash on 30/01/25.
//

import Foundation
import SwiftUI
import Firebase
func generateUniquePatientID(completion: @escaping (String?) -> Void) {
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var generatedID: String?

    func checkIfPatientIDExists(_ id: String) {
        let db = Firestore.firestore()
        db.collection("users").whereField("patientID", isEqualTo: id).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking patient ID: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if snapshot?.isEmpty == true {
                completion(id)
            } else {
                generatedID = String((0..<6).compactMap { _ in characters.randomElement() })
                checkIfPatientIDExists(generatedID!)
            }
        }
    }

    generatedID = String((0..<6).compactMap { _ in characters.randomElement() })
    if let generatedID = generatedID {
        checkIfPatientIDExists(generatedID)
    }
}
