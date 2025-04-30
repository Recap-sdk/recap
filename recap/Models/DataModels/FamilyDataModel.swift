//
//  FamilyDataModel.swift
//  recap
//
//  Created by Diptayan Jash on 05/11/24.
//

import Foundation
import UIKit

enum RelationshipCategory: String, Codable, CaseIterable {
    case Son, Daughter, Husband, Wife, Father, Mother, Brother, Sister
}

struct FamilyMember: Codable, Identifiable, Equatable {
    var id: String  // Correct type declaration for `id`
    let name: String
    let relationship: String
    let phone: String
    let email: String
    let password: String
    let imageName: String
    let imageURL: String

    // Convert FamilyMember to a dictionary (useful for Firebase)
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "relationship": relationship,
            "phone": phone,
            "email": email,
            "password": password,
            "imageName": imageName,
            "imageURL": imageURL,
        ]
    }
}

// Example data for family members (with valid IDs)
var familyMembers = [
    FamilyMember(
        id: UUID().uuidString,  // Generate a unique ID for each family member
        name: "Bobby Deol",
        relationship: "Brother",
        phone: "8208457322",
        email: "contact@djdiptayan.in",
        password: "password",
        imageName: "familyImg",
        imageURL: "https://as1.ftcdn.net/v2/jpg/02/99/04/20/1000_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg"
    ),
    FamilyMember(
        id: UUID().uuidString,
        name: "Charlie Puth",
        relationship: "Son",
        phone: "8208457322",
        email: "contact@djdiptayan.in",
        password: "password",
        imageName: "familyImg",
        imageURL: "https://as1.ftcdn.net/v2/jpg/02/99/04/20/1000_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg"
    ),
    FamilyMember(
        id: UUID().uuidString,
        name: "Jack Puth",
        relationship: "Husband",
        phone: "8208457322",
        email: "contact@djdiptayan.in",
        password: "password",
        imageName: "familyImg",
        imageURL: "https://as1.ftcdn.net/v2/jpg/02/99/04/20/1000_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg"
    )
]
