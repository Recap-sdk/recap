//
//  Constants.swift
//  recap
//
//  Created by Diptayan Jash on 05/02/25.
//

import Foundation
import UIKit

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
    
    enum paddingKeys{
        static let DefaultPaddingLeft = 16.0
        static let DefaultPaddingRight = -16.0
        static let DefaultPaddingTop = 10.0
        static let DefaultPaddingBottom = -16.0
    }
    enum CardSize{
        static let DefaultCardHeight = 160.0
        static let DefaultCardWidth = 180.0
        static let DefaultCardCornerRadius = 15.0
    }
    
    enum FontandColors {
        // Font definitions
        static let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)       // SF Pro Bold
        static let subtitleFont = UIFont.systemFont(ofSize: 18, weight: .regular) // SF Pro Display Regular
        static let descriptionFont = UIFont.systemFont(ofSize: 16, weight: .light) // SF Pro Display Light
        
        // Colors (converted to UIColor for immediate use)
        static let titleColor = UIColor.black
        static let subtitleColor = UIColor.gray
        static let descriptionColor = UIColor.systemGray2
        static let chevronName = "chevron.right"
        static let chevronColor = UIColor.gray
        
        static let defaultshadowColor = UIColor.black.cgColor
        static let defaultshadowOpacity = 0.1
        static let defaultshadowOffset = CGSize(width: 0, height: 2)
        static let defaultshadowRadius = 2.0
    }

    enum NotificationNames {
        static let FamilyMemberAdded = "FamilyMemberAdded"
    }
}
