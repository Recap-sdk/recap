//
//  MemoryGameViewController.swift
//  recap
//
//  Created by Diptayan Jash on 06/03/25.
//
import AudioToolbox
import Foundation
import UIKit

class MemoryGameViewController: UIViewController {
    // MARK: - Properties

    private var cardButtons = [UIButton]()
    private var cardImages = [UIImage]()
    private var flippedCards = [UIButton]()
    private var matchedCards = [UIButton]()
    private var timer: Timer?
    private var secondsElapsed = 0
    private var moves = 0

    private let gridSize = 4 // 4x4 grid (16 cards, 8 pairs)
    private let cardSpacing: CGFloat = 12.0
    private let animationDuration = 0.5

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Matches: 0"
        label.font = Constants.FontandColors.titleFont
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Time: 0s"
        label.font = Constants.FontandColors.titleFont
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    private lazy var movesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Moves: 0"
        label.font = Constants.FontandColors.titleFont
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }()

    private lazy var newGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Game", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = AppColors.primaryButtonColor
        button
            .setTitleColor(
                AppColors.primaryButtonTextColor,
                for: .normal
            )
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.addTarget(self, action: #selector(startNewGame), for: .touchUpInside)
        return button
    }()

    // MARK: - Instruction View Properties

    private var instructionOverlayView: UIView?

    private lazy var instructionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.layer.shadowColor = Constants.FontandColors.defaultshadowColor
        view.layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        view.layer.shadowRadius = Constants.FontandColors.defaultshadowRadius
        view.layer.shadowOpacity = Float(
            Constants.FontandColors.defaultshadowRadius
        )
        return view
    }()

    private lazy var instructionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "How to Play"
        label.font = Constants.FontandColors.titleFont
        label.textAlignment = .center
        label.textColor = Constants.FontandColors.titleColor
        return label
    }()

    private lazy var instructionTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1. Tap cards to flip them over\n2. Find matching pairs of cards\n3. Match all pairs to win\n4. Try to complete the game with fewer moves and in less time"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = .darkGray
        return label
    }()

    private lazy var startGameButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Game", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = AppColors.primaryButtonColor
        button
            .setTitleColor(
                AppColors.primaryButtonTextColor,
                for: .normal
            )
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        button.addTarget(self, action: #selector(dismissInstructions), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAccessibility()
        loadCardImages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Show instructions on first appearance
        showInstructions()
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.BGs.GreyBG
        title = "Memory Match Game"

        // Add subviews
        view.addSubview(scoreLabel)
        view.addSubview(timeLabel)
        view.addSubview(movesLabel)
        view.addSubview(containerView)
        view.addSubview(newGameButton)

        // Setup constraints
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),

            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            movesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            movesLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            containerView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 30),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalTo: containerView.widthAnchor),

            newGameButton.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 30),
            newGameButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newGameButton.widthAnchor.constraint(equalToConstant: 200),
            newGameButton.heightAnchor.constraint(equalToConstant: 60),
            newGameButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

    private func setupAccessibility() {
        // Make the game accessible
        scoreLabel.isAccessibilityElement = true
        timeLabel.isAccessibilityElement = true
        movesLabel.isAccessibilityElement = true
        newGameButton.isAccessibilityElement = true

        scoreLabel.accessibilityTraits = .updatesFrequently
        timeLabel.accessibilityTraits = .updatesFrequently
        movesLabel.accessibilityTraits = .updatesFrequently

        newGameButton.accessibilityHint = "Starts a new memory matching game"
    }

    private func createGameBoard() {
        // Remove existing cards
        for subview in containerView.subviews {
            subview.removeFromSuperview()
        }
        cardButtons.removeAll()

        // Calculate card size based on container size
        let availableWidth = containerView.bounds.width
        let cardSize = (availableWidth - (cardSpacing * CGFloat(gridSize - 1))) / CGFloat(gridSize)

        // Create and position cards
        for row in 0 ..< gridSize {
            for column in 0 ..< gridSize {
                let cardButton = createCardButton()
                containerView.addSubview(cardButton)

                // Position the card
                let x = CGFloat(column) * (cardSize + cardSpacing)
                let y = CGFloat(row) * (cardSize + cardSpacing)

                cardButton.frame = CGRect(x: x, y: y, width: cardSize, height: cardSize)
                cardButtons.append(cardButton)
            }
        }
    }

    private func createCardButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 3
        button.layer.shadowOpacity = 0.2

        // Set the card back image
        let cardBackImage = UIImage(systemName: "questionmark.circle.fill")
        button.setImage(cardBackImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.imageEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        button.tintColor = AppColors.iconColor.withAlphaComponent(0.7)

        button.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)

        // Accessibility
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Card"
        button.accessibilityHint = "Double tap to flip this card"

        return button
    }

    private func loadCardImages() {
        // Simple images that are distinct and recognizable for seniors
        let imageNames = [
            "house.fill", "star.fill", "heart.fill", "bell.fill",
            "sun.max.fill", "moon.fill", "leaf.fill", "car.fill",
        ]

        // Load images and create pairs
        for name in imageNames {
            if let image = UIImage(systemName: name) {
                cardImages.append(image)
                cardImages.append(image) // Duplicate for pairs
            }
        }
    }

    // MARK: - Instruction Methods

    private func showInstructions() {
        // Create blurred overlay
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.alpha = 0
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        // Add instruction view and subviews
        view.addSubview(instructionView)
        instructionView.addSubview(instructionTitleLabel)
        instructionView.addSubview(instructionTextLabel)
        instructionView.addSubview(startGameButton)

        NSLayoutConstraint.activate(
[
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            instructionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            instructionView.leadingAnchor
                .constraint(
                    equalTo: view.leadingAnchor,
                    constant: Constants.paddingKeys
                        .DefaultPaddingLeft),
            instructionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.paddingKeys.DefaultPaddingRight),
            instructionView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),

            instructionTitleLabel.topAnchor.constraint(equalTo: instructionView.topAnchor, constant: 24),
            instructionTitleLabel.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 24),
            instructionTitleLabel.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -24),

            instructionTextLabel.topAnchor.constraint(equalTo: instructionTitleLabel.bottomAnchor, constant: 24),
            instructionTextLabel.leadingAnchor.constraint(equalTo: instructionView.leadingAnchor, constant: 24),
            instructionTextLabel.trailingAnchor.constraint(equalTo: instructionView.trailingAnchor, constant: -24),

            startGameButton.topAnchor.constraint(equalTo: instructionTextLabel.bottomAnchor, constant: 32),
            startGameButton.centerXAnchor.constraint(equalTo: instructionView.centerXAnchor),
            startGameButton.widthAnchor.constraint(equalToConstant: 200),
            startGameButton.heightAnchor.constraint(equalToConstant: 60),
            startGameButton.bottomAnchor.constraint(equalTo: instructionView.bottomAnchor, constant: -24),
        ]
)

        // Save reference for dismissal
        instructionOverlayView = blurView

        // Animation for blur and instruction card
        instructionView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        instructionView.alpha = 0

        UIView.animate(withDuration: 0.3) {
            blurView.alpha = 1
            self.instructionView.alpha = 1
            self.instructionView.transform = .identity
        }

        // Setup accessibility
        instructionView.isAccessibilityElement = true
        instructionView.accessibilityLabel = "Game Instructions"
        instructionView.accessibilityHint = "Learn how to play the game"
        UIAccessibility.post(notification: .screenChanged, argument: instructionView)
    }

    @objc private func dismissInstructions() {
        // Dismiss instructions with animation
        UIView.animate(withDuration: 0.3, animations: {
            self.instructionView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.instructionView.alpha = 0
            self.instructionOverlayView?.alpha = 0
        }) { _ in
            self.instructionOverlayView?.removeFromSuperview()
            self.instructionOverlayView = nil
            // Start the game after dismissing instructions
            self.startNewGame()
        }
    }

    // MARK: - Game Logic

    @objc private func startNewGame() {
        // Reset game state
        flippedCards.removeAll()
        matchedCards.removeAll()
        secondsElapsed = 0
        moves = 0

        // Update UI
        scoreLabel.text = "Matches: 0"
        timeLabel.text = "Time: 0s"
        movesLabel.text = "Moves: 0"

        // Shuffle and deal cards
        cardImages.shuffle()
        createGameBoard()

        // Start timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        // Announce new game started for accessibility
        UIAccessibility.post(notification: .announcement, argument: "New game started. Find matching pairs of cards.")
    }

    @objc private func cardTapped(_ sender: UIButton) {
        // Ignore taps on matched cards or if two cards are already flipped
        guard !matchedCards.contains(sender) && flippedCards.count < 2 && !flippedCards.contains(sender) else {
            return
        }

        // Flip the card
        flipCard(sender)
        flippedCards.append(sender)

        // Check for a match if two cards are flipped
        if flippedCards.count == 2 {
            moves += 1
            movesLabel.text = "Moves: \(moves)"

            // Check for a match
            let firstCardIndex = cardButtons.firstIndex(of: flippedCards[0])!
            let secondCardIndex = cardButtons.firstIndex(of: flippedCards[1])!

            if cardImages[firstCardIndex] == cardImages[secondCardIndex] {
                // Match found
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    self.handleMatch()
                }
            } else {
                // No match
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    guard let self = self else { return }
                    self.resetFlippedCards()
                }
            }
        }
    }

    private func flipCard(_ card: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        // If card is already flipped, show its image
        if let cardIndex = cardButtons.firstIndex(of: card) {
            UIView.transition(with: card, duration: animationDuration, options: .transitionFlipFromLeft, animations: {
                // Show the card image
                card.setImage(self.cardImages[cardIndex], for: .normal)
                card.tintColor = .systemIndigo
                card.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            }, completion: nil)

            // Update accessibility
            card.accessibilityLabel = "Flipped card showing \(cardIndex)"
        }
    }

    private func flipCardBack(_ card: UIButton) {
        UIView.transition(with: card, duration: animationDuration, options: .transitionFlipFromRight, animations: {
            // Show the card back
            card.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
            card.tintColor = AppColors.iconColor.withAlphaComponent(0.7)
            card.backgroundColor = .white
        }, completion: nil)

        // Update accessibility
        card.accessibilityLabel = "Card"
    }

    private func handleMatch() {
        // Handle matched cards
        for card in flippedCards {
            matchedCards.append(card)

            // Animate a success indicator
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.3) {
                card.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            } completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    card.transform = .identity
                    card.layer.borderColor = UIColor.green.cgColor
                    card.layer.borderWidth = 3.0
                }
            }
        }

        // Clear flipped cards array
        flippedCards.removeAll()

        // Update score
        let matchCount = matchedCards.count / 2
        scoreLabel.text = "Matches: \(matchCount)"

        // Announce match for accessibility
        UIAccessibility.post(notification: .announcement, argument: "Match found! \(matchCount) pairs matched.")

        // Check if game is completed
        if matchedCards.count == cardButtons.count {
            gameCompleted()
        }
    }

    private func resetFlippedCards() {
        // Flip cards back if they don't match
        for card in flippedCards {
            flipCardBack(card)
        }
        flippedCards.removeAll()
    }
    private func gameCompleted() {
        // Stop timer
        timer?.invalidate()
        
        // Play multiple haptics in sequence
        let notificationGenerator = UINotificationFeedbackGenerator()
        notificationGenerator.notificationOccurred(.success)
        
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        }
        
        // Play a success sound
        AudioServicesPlaySystemSound(1025) // System sound for success (You can change it)
        
        // Animate the view slightly before presenting the completion screen
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.view.transform = CGAffineTransform.identity
            })
        }
        
        // Delay presenting the completion screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let completionVC = GameCompletionViewController()
            completionVC.secondsElapsed = self.secondsElapsed
            completionVC.moves = self.moves
            completionVC.modalPresentationStyle = .overFullScreen
            completionVC.modalTransitionStyle = .crossDissolve
            
            completionVC.onPlayAgainTapped = { [weak self] in
                self?.startNewGame()
            }
            
            completionVC.onExitTapped = {
                self.navigationController?.popViewController(animated: true)
            }
            
            self.present(completionVC, animated: true, completion: nil)
            
            // Accessibility announcement
            UIAccessibility.post(notification: .announcement, argument: "Congratulations! You completed the game!")
        }
    }
    

    @objc private func updateTimer() {
        secondsElapsed += 1
        timeLabel.text = "Time: \(secondsElapsed)s"
    }
}
#Preview {
    MemoryGameViewController()
}
