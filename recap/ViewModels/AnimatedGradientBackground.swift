//
//  AnimatedGradientBackground.swift
//  recap
//
//  Created by Diptayan Jash on 04/03/25.
//

import Foundation
import UIKit

class AnimatedGradientBackground: NSObject {
    // Container layer for the animation
    private let gradientLayer = CAGradientLayer()

    // Array of gradient colors to cycle through
    private let colorSets: [[CGColor]] = [
        // Health app-like colors - soothing blues to pinks to purples
        [
            UIColor(red: 0.42, green: 0.55, blue: 0.97, alpha: 1.0).cgColor,
            UIColor(red: 0.72, green: 0.53, blue: 0.93, alpha: 1.0).cgColor,
        ],
        [
            UIColor(red: 0.72, green: 0.53, blue: 0.93, alpha: 1.0).cgColor,
            UIColor(red: 0.94, green: 0.42, blue: 0.71, alpha: 1.0).cgColor,
        ],
        [
            UIColor(red: 0.94, green: 0.42, blue: 0.71, alpha: 1.0).cgColor,
            UIColor(red: 0.40, green: 0.76, blue: 0.93, alpha: 1.0).cgColor,
        ],
        [
            UIColor(red: 0.40, green: 0.76, blue: 0.93, alpha: 1.0).cgColor,
            UIColor(red: 0.42, green: 0.55, blue: 0.97, alpha: 1.0).cgColor,
        ],
    ]

    private var colorIndex = 0
    private var rotationAnimation: CABasicAnimation?
    private var extendedFrame: CGRect = .zero
    
    // Setup gradient background on view with extended size for scrolling
    func setupGradient(for view: UIView, scrollableHeight: CGFloat = 1000) {
        // Create an extended frame that's taller than the view for scrolling
        extendedFrame = CGRect(x: 0, y: -scrollableHeight / 2,
                               width: view.bounds.width,
                               height: view.bounds.height + scrollableHeight)

        // Configure the gradient layer
        gradientLayer.colors = colorSets[colorIndex]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.frame = extendedFrame

        // Insert at the bottom of the layer stack
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Start the animation
        animateGradient()
        animateRotation()
    }

    // Update gradient position based on scroll offset
    func updateForScrollPosition(yOffset: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        // Move gradient layer based on scroll
        let newPosition = extendedFrame.origin.y + (yOffset * 0.5) // Parallax effect (0.5 = half speed)
        gradientLayer.frame.origin.y = newPosition
        CATransaction.commit()
    }

    // Called when device orientation changes or view size changes
    func updateGradientFrame(for view: UIView, scrollableHeight: CGFloat = 1000) {
        extendedFrame = CGRect(x: 0, y: -scrollableHeight / 2,
                               width: view.bounds.width,
                               height: view.bounds.height + scrollableHeight)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = extendedFrame
        CATransaction.commit()
    }

    // Animate between gradient colors
    private func animateGradient() {
        // Move to next color set
        colorIndex = (colorIndex + 1) % colorSets.count

        // Create animation
        let colorChangeAnimation = CABasicAnimation(keyPath: "colors")
        colorChangeAnimation.duration = 4.0 // Animation duration
        colorChangeAnimation.toValue = colorSets[colorIndex]
        colorChangeAnimation.fillMode = .forwards
        colorChangeAnimation.isRemovedOnCompletion = false
        colorChangeAnimation.delegate = self

        // Apply animation
        gradientLayer.add(colorChangeAnimation, forKey: "colorChange")
    }

    // Add rotation animation to the gradient
    private func animateRotation() {
        // Create rotation animation
        let fullRotation = CGFloat.pi * 2
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = fullRotation
        rotationAnimation.duration = 20.0 // Slower rotation
        rotationAnimation.repeatCount = .infinity

        // Add rotation animation
        gradientLayer.add(rotationAnimation, forKey: "rotationAnimation")

        self.rotationAnimation = rotationAnimation
    }
}

// MARK: - Animation Delegate

extension AnimatedGradientBackground: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag && anim == gradientLayer.animation(forKey: "colorChange") {
            gradientLayer.colors = colorSets[colorIndex]
            animateGradient()
        }
    }
}
