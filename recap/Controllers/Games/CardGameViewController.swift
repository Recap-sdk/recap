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
    private let previewBackgroundView = UIView()
    private let previewGridView = UIStackView()
    private var previewTimer: Timer?

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
        title = "Card Game"
        
        // Card Image View
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.image = UIImage(named: "card_back") // Add a card back image in assets
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardImageView)
        
        // Score Label
        scoreLabel.text = "Score: 0"
        scoreLabel.textAlignment = .center
        scoreLabel.font = .boldSystemFont(ofSize: 24)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Higher Button
        higherButton.setTitle("Higher", for: .normal)
        higherButton.backgroundColor = .systemGreen
        higherButton.layer.cornerRadius = 10
        higherButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        higherButton.setTitleColor(.white, for: .normal)
        higherButton.addTarget(self, action: #selector(higherButtonTapped), for: .touchUpInside)
        higherButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(higherButton)
        
        // Lower Button
        lowerButton.setTitle("Lower", for: .normal)
        lowerButton.backgroundColor = .systemRed
        lowerButton.layer.cornerRadius = 10
        lowerButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        lowerButton.setTitleColor(.white, for: .normal)
        lowerButton.addTarget(self, action: #selector(lowerButtonTapped), for: .touchUpInside)
        lowerButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lowerButton)
        
        // Preview Background View (for blur effect)
        previewBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        previewBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        previewBackgroundView.isHidden = true
        view.addSubview(previewBackgroundView)
        
        // Preview Grid View
        previewGridView.axis = .vertical
        previewGridView.alignment = .fill
        previewGridView.distribution = .fillEqually
        previewGridView.spacing = 10
        previewGridView.translatesAutoresizingMaskIntoConstraints = false
        previewBackgroundView.addSubview(previewGridView)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            previewBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            previewBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            previewBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            previewGridView.centerXAnchor.constraint(equalTo: previewBackgroundView.centerXAnchor),
            previewGridView.centerYAnchor.constraint(equalTo: previewBackgroundView.centerYAnchor),
            previewGridView.widthAnchor.constraint(equalTo: previewBackgroundView.widthAnchor, multiplier: 0.9),
            previewGridView.heightAnchor.constraint(equalTo: previewBackgroundView.heightAnchor, multiplier: 0.5),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            cardImageView.widthAnchor.constraint(equalToConstant: 200),
            cardImageView.heightAnchor.constraint(equalToConstant: 300),
            
            higherButton.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 20),
            higherButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            higherButton.widthAnchor.constraint(equalToConstant: 120),
            higherButton.heightAnchor.constraint(equalToConstant: 50),
            
            lowerButton.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 20),
            lowerButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            lowerButton.widthAnchor.constraint(equalToConstant: 120),
            lowerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func resetGame() {
        deck = Array(1...13).shuffled()
        score = 0
        scoreLabel.text = "Score: \(score)"
        setupPreviewGrid()
    }
    
    private func setupPreviewGrid() {
        previewGridView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let rows = 3
        let columns = 5
        var cardIndex = 0
        
        for _ in 0..<rows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 10
            
            for _ in 0..<columns {
                if cardIndex < deck.count {
                    let cardPreview = UIImageView()
                    cardPreview.image = UIImage(named: "card_\(deck[cardIndex])")
                    cardPreview.contentMode = .scaleAspectFit
                    cardPreview.clipsToBounds = true
                    cardPreview.layer.cornerRadius = 8
                    rowStackView.addArrangedSubview(cardPreview)
                    cardIndex += 1
                }
            }
            previewGridView.addArrangedSubview(rowStackView)
        }
        
        // Show preview with blur effect
        previewBackgroundView.isHidden = false
        
        // Start timer to hide preview after a few seconds
        previewTimer?.invalidate()
        previewTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(hidePreview), userInfo: nil, repeats: false)
    }
    
    @objc private func hidePreview() {
        previewBackgroundView.isHidden = true
        drawCard()
    }
    
    private func drawCard() {
        if let newCard = deck.popLast() {
            currentCard = newCard
            updateCardImage(for: newCard)
            animateCardFlip()
        } else {
            endGame()
        }
    }
    
    private func updateCardImage(for card: Int) {
        cardImageView.image = UIImage(named: "card_\(card)")
    }
    
    private func animateCardFlip() {
        UIView.transition(with: cardImageView, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
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
