//
//  Color.swift
//  Recap
//
//  Created by khushi on 30/11/24.
//

import UIKit
import SwiftUI

struct ColorTheme {
    static let primary = UIColor(hex: "#6A0DAD")
    static let secondary = UIColor(hex: "#B19CD9")
    static let accent = UIColor(hex: "#D8BFD8")
    static let background = UIColor(hex: "#F3E5F5")
    static let textLight = UIColor(hex: "#4A148C")
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Color {
    static let customLightRed = Color(red: 1.0, green: 0.5725, blue: 0.5412)
    static let customLightPurple = Color(red: 0.5373, green: 0.4745, blue: 1.0)
    static let customBlue = Color(red: 0.2941, green: 0.4392, blue: 0.9608)
    static let customGreen = Color(red: 0.4549, green: 0.7618, blue: 0.3529)
    static let customLightBlueGray = Color(red: 0.7255, green: 0.8078, blue: 0.8588)
    static let customLightGray = Color(red: 0.8902, green: 0.8667, blue: 0.8667)
    static let customSoftYellow = Color(red: 1.0, green: 0.9019, blue: 0.4275)
    
    static let primary = Color(UIColor(hex: "#6A0DAD"))
    static let secondary = Color(UIColor(hex: "#B19CD9"))
    static let accent = Color(UIColor(hex: "#D8BFD8"))
    static let background = Color(UIColor(hex: "#F3E5F5"))
    static let textLight = Color(UIColor(hex: "#4A148C"))
}

extension UIButton {
    func addGradient(colors: [CGColor], startPoint: CGPoint, endPoint: CGPoint) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        
        // Remove existing gradient layers to avoid duplicates
        layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
