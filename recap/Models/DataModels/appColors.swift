//
//  appColors.swift
//  recap
//
//  Created by admin70 on 25/03/25.
//
import UIKit
struct AppColors {
    // MARK: - Primary Colors
//    static let primaryButtonColor = UIColor(red: 0.60, green: 0.80, blue: 0.80, alpha: 1.0)  // Teal-like color for 'Save' button
//    static let savedButtonColor = UIColor(red: 0.80, green: 0.60, blue: 0.70, alpha: 1.0)   // Soft rose color for 'Saved' button
    static let primaryButtonColor = iconColor.withAlphaComponent(0.2)  // Light Lavender Purple for primary buttons
    static let savedButtonColor = iconColor.withAlphaComponent(0.1)


    // MARK: - Background Gradient Colors
    static let gradientStartColor = UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0)  // Light teal
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

//import UIKit
//
//struct AppColors {
//    // MARK: - Purple Themed Colors
//    static let primaryButtonColor = UIColor(appHex: "#6A0DAD")  // Royal Purple for primary buttons
//    static let savedButtonColor = UIColor(appHex: "#7E57C2")    // Soft Lavender Purple for saved buttons
//    
//    // MARK: - Background Gradient Colors (Unchanged)
//    static let gradientStartColor = UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0)  // Light teal
//    static let gradientEndColor = UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0)    // Soft rose-pink
//    
//    // MARK: - Card Background Colors
////    static let cardBackgroundColor = UIColor(appHex: "#EDE7F6")  // Lavender Mist for card backgrounds
//    static let cardBackgroundColor = UIColor(appHex: "#FFFFFF")
//    
//    // MARK: - Icon and Symbol Colors
//    static let iconColor = UIColor(appHex: "#6A0DAD")           // Royal Purple for icons
//    static let selectedIconColor = UIColor(appHex: "#4A148C")   // Deep Purple for selected icons
//    
//    // MARK: - Text Colors
//    static let primaryTextColor = UIColor(appHex: "#4A148C")    // Deep Purple for primary text
//    static let secondaryTextColor = UIColor(appHex: "#6A0DAD")  // Royal Purple for secondary text
//    static let inverseTextColor = UIColor.white                 // White text for darker backgrounds
//    
//    // MARK: - Button Colors
//    static let primaryButtonTextColor = UIColor.white           // White text on primary buttons
//    static let secondaryButtonColor = UIColor(appHex: "#D1C4E9") // Light Lavender for secondary buttons
//    static let secondaryButtonTextColor = UIColor(appHex: "#6A0DAD")  // Medium Purple for text on secondary buttons
//    
//    // MARK: - Interactive Colors
//    static let highlightColor = UIColor(appHex: "#9575CD")  // Lavender Purple for highlights
//    static let errorColor = UIColor(appHex: "#D500F9")      // Bright Purple for errors
//    static let successColor = UIColor(appHex: "#9C27B0")    // Strong Purple for success messages
//    
//    // MARK: - Gradient Layer for Background
//    static func createAppBackgroundGradientLayer() -> CAGradientLayer {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            AppColors.gradientStartColor.cgColor,
//            AppColors.gradientEndColor.cgColor,
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
//        return gradientLayer
//    }
//    
//    // MARK: - Accessibility Helpers
//    static func getContrastingTextColor(for backgroundColor: UIColor) -> UIColor {
//        let luminance = (0.299 * backgroundColor.components.red +
//                         0.587 * backgroundColor.components.green +
//                         0.114 * backgroundColor.components.blue)
//        return luminance > 0.5 ? primaryTextColor : inverseTextColor
//    }
//}
//
//// MARK: - UIColor Hex Extension
//extension UIColor {
//    convenience init(appHex hex: String) {
//        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
//        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
//        
//        var rgb: UInt64 = 0
//        Scanner(string: hexSanitized).scanHexInt64(&rgb)
//        
//        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
//        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
//        let blue = CGFloat(rgb & 0x0000FF) / 255.0
//        
//        self.init(red: red, green: green, blue: blue, alpha: 1.0)
//    }
//    
//    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var a: CGFloat = 0
//        getRed(&r, green: &g, blue: &b, alpha: &a)
//        return (r, g, b, a)
//    }
//}
