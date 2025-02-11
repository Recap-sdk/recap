//
//  Constants.swift
//  recap
//
//  Created by Diptayan Jash on 05/02/25.
//

import Foundation

enum Constants {
    enum UserDefaultsKeys {
        static let isFamilyMemberLoggedIn = "isUserLoggedIn"
        static let hasPatientCompletedProfile = "hasCompletedProfile"
        static let verifiedUserDocID = "verifiedUserDocID"
        static let familyMemberDetails = "familyMemberDetails"
        static let familyMemberImageURL = "familyMemberImageURL"
        static let patientDetails = "patientDetails"

        static let patientProfile = "patientProfile"
        static let isPatientLoggedIn = "isPatientLoggedIn"
    }

    enum FirestoreKeys {
        static let usersCollection = "users"
        static let ArticleCollection = "Articles"
        static let familyMembersCollection = "family_members"
        static let RapidQuestionDBName = "rapidMemoryQuestions"
        static let RapidQuestionReport = "memoryCheckReports"
        
    }

    enum StorageKeys {
        static let profileImage = "profileImage"
        static let patientProfile = "PatientProfile"
    }

    enum NotificationNames {
        static let familyMemberAdded = "familyMemberAdded"
    }
}
