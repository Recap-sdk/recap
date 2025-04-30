//
//  LoadingAnimationManager.swift
//  recap
//
//  Created by Diptayan Jash on 05/03/25.
//
import Foundation
import Lottie
import UIKit

class LoadingAnimationManager {
    static let shared = LoadingAnimationManager()

    private init() {}

    func showLoadingAnimation(on view: UIView, name: String = "loadingAnimation") -> LottieAnimationView {
        guard let animation = LottieAnimation.named("loadingAnimation", bundle: .main) else {
            fatalError("Lottie file not found")
        }
        let lottieView = LottieAnimationView(animation: animation)
        lottieView.contentMode = .scaleAspectFit
        lottieView.loopMode = .loop
        lottieView.translatesAutoresizingMaskIntoConstraints = false

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(backgroundView)
        view.addSubview(lottieView)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        NSLayoutConstraint.activate([
            lottieView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lottieView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            lottieView.widthAnchor.constraint(equalToConstant: 250),
            lottieView.heightAnchor.constraint(equalToConstant: 250),
        ])

        // Play animation
        lottieView.play()

        return lottieView
    }

    func removeLoadingAnimation(_ animationView: LottieAnimationView) {
        animationView.stop()

        // Remove both the animation view and its background
        if let backgroundView = animationView.superview?.subviews.first(where: { $0 is UIView && $0 != animationView }) {
            backgroundView.removeFromSuperview()
        }
        animationView.removeFromSuperview()
    }
}

// Optional: Extension to make it easier to use in view controllers
extension UIViewController {
    func showLoadingAnimation(name: String = "LoadingAnimation") -> LottieAnimationView {
        return LoadingAnimationManager.shared.showLoadingAnimation(on: view, name: name)
    }

    func removeLoadingAnimation(_ animationView: LottieAnimationView) {
        LoadingAnimationManager.shared.removeLoadingAnimation(animationView)
    }
}
