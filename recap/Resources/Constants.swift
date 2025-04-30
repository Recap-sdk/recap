//
//  Constants.swift
//  recap
//
//  Created by Diptayan Jash on 05/02/25.
//

import Foundation
import UIKit

enum Constants {
    enum BGs{
        static let GreyBG = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    }
    
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
    enum ButtonStyle{
        static let DefaultButtonHeight = 56.0
        static let DefaultButtonWidth = 120.0
        static let DefaultButtonCornerRadius = 15.0
        static let DefaultButtonFontSize = 12.0
        static let DefaultButtonFont = UIFont.boldSystemFont(ofSize: 18)
        static let DefaultButtonBackgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
        static let DefaultButtonTextColor = UIColor.systemBlue
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
struct AppColors {
    // MARK: - Primary Colors
    static let primaryButtonColor = iconColor.withAlphaComponent(0.2)
    static let savedButtonColor = iconColor.withAlphaComponent(0.1)


    // MARK: - Background Gradient Colors
    static let gradientStartColor = UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0)
    static let gradientEndColor = UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0)    // Soft rose-pink
    
    
     // MARK: - Card Background Colors
 //    static let cardBackgroundColor = UIColor(appHex: "#EDE7F6")  // Lavender Mist for card backgrounds
     static let cardBackgroundColor = UIColor(hex: "#F4F6FF")
    // MARK: - icon Colors
    static let iconColor = UIColor(hex: "#0B8494")  // Teal-blue base

    // MARK: - Icon and Symbol Colors
    static let selectedIconColor = iconColor  // Same as base for consistency
    

    // MARK: - Text Colors
    static let primaryButtonTextColor = iconColor

    // MARK: - Text Colors
        static let primaryTextColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)  // Dark charcoal for better readability
        static let secondaryTextColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)  // Medium gray for secondary text
        static let inverseTextColor = UIColor.white  // White text for use on darker backgrounds
    // MARK: - Button Colors

    static let secondaryButtonColor = iconColor.withAlphaComponent(0.1)
    static let secondaryButtonTextColor = iconColor


    // MARK: - Interactive Colors
    static let highlightColor = iconColor.withAlphaComponent(0.3)
    static let errorColor = UIColor(red: 0.90, green: 0.40, blue: 0.40, alpha: 1.0)  // Keeping error red
    static let successColor = UIColor(red: 0.40, green: 0.80, blue: 0.40, alpha: 1.0)

    // MARK: - Gradient Layer for Background
    static func createAppBackgroundGradientLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            AppColors.gradientStartColor.cgColor,
            AppColors.gradientEndColor.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradientLayer
    }

    // MARK: - Accessibility Helpers
    static func getContrastingTextColor(for backgroundColor: UIColor) -> UIColor {
        // Simple luminance calculation to determine text color
        let luminance = (0.299 * backgroundColor.components.red +
                         0.587 * backgroundColor.components.green +
                         0.114 * backgroundColor.components.blue)
        return luminance > 0.5 ? primaryTextColor : inverseTextColor
    }
}

// Extension to help with color component access
extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}
