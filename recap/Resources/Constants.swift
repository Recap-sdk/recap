//
//  Constants.swift
//  recap
//
//  Created by Diptayan Jash on 05/02/25.
//

import Foundation

enum Constants {
    enum UserDefaultsKeys {
        static let HasCompletedOnboarding = "HasCompletedOnboarding"
        
        static let isFamilyMemberLoggedIn = "isUserLoggedIn"
        static let hasPatientCompletedProfile = "hasCompletedProfile"
        
        static let verifiedUserDocID = "verifiedUserDocID"
        
        static let familyMemberDetails = "familyMemberDetails"
        static let familyMemberImageURL = "familyMemberImageURL"
        
        static let isPatientLoggedIn = "isPatientLoggedIn"
        static let patientDetails = "patientDetails"
    }

    enum FirestoreKeys {
        static let usersCollection = "users"
        static let familyMembersCollection = "family_members"
    }

    enum StorageKeys {
    }

    enum NotificationNames {
        static let FamilyMemberAdded = "FamilyMemberAdded"
    }
}
