//
//  CardGameViewController.swift
//  recap
//
//  Created by Diptayan Jash on 09/01/25.
//

import UIKit

class CardGameViewController: UIViewController {
    
    // UI Elements
    private let cardImageView = UIImageView()
    private let higherButton = UIButton(type: .system)
    private let lowerButton = UIButton(type: .system)
    private let scoreLabel = UILabel()
    
    // Game Data
    private var deck = [Int]() // Deck of cards (1 to 13 represent Ace to King)
    private var currentCard: Int = 0
    private var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        resetGame()
        applyGradientBackground()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Higher or Lower"
        
        // Card Image View
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.image = UIImage(named: "card_back") // Add a card back image in assets
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardImageView)
        
        // Score Label
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .center
        scoreLabel.font = .boldSystemFont(ofSize: 20)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Higher Button
        higherButton.setTitle("Higher", for: .normal)
        higherButton.addTarget(self, action: #selector(higherButtonTapped), for: .touchUpInside)
        higherButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(higherButton)
        
        // Lower Button
        lowerButton.setTitle("Lower", for: .normal)
        lowerButton.addTarget(self, action: #selector(lowerButtonTapped), for: .touchUpInside)
        lowerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerButton)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            cardImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            cardImageView.widthAnchor.constraint(equalToConstant: 200),
            cardImageView.heightAnchor.constraint(equalToConstant: 300),
            
            scoreLabel.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            higherButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            higherButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            higherButton.widthAnchor.constraint(equalToConstant: 100),
            higherButton.heightAnchor.constraint(equalToConstant: 50),
            
            lowerButton.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 20),
            lowerButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            lowerButton.widthAnchor.constraint(equalToConstant: 100),
            lowerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func resetGame() {
        deck = Array(1...13).shuffled()
        score = 0
        scoreLabel.text = "Score: \(score)"
        drawCard()
    }
    
    private func drawCard() {
        if let newCard = deck.popLast() {
            currentCard = newCard
            updateCardImage(for: newCard)
        } else {
            endGame()
        }
    }
    
    private func updateCardImage(for card: Int) {
        cardImageView.image = UIImage(named: "card_\(card)") // Add card images named like "card_1", "card_2" in assets
    }
    
    private func endGame() {
        let alert = UIAlertController(
            title: "Game Over",
            message: "Your final score is \(score)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true)
    }
    
    @objc private func higherButtonTapped() {
        guess(higher: true)
    }
    
    @objc private func lowerButtonTapped() {
        guess(higher: false)
    }
    
    private func guess(higher: Bool) {
        guard let nextCard = deck.last else { return }
        
        if (higher && nextCard > currentCard) || (!higher && nextCard < currentCard) {
            score += 1
        } else {
            score -= 1
        }
        
        scoreLabel.text = "Score: \(score)"
        drawCard()
    }
    
    private func applyGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
            UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
