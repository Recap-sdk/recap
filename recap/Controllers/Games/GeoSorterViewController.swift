import AudioToolbox
import Foundation
import UIKit

class GeoSorterViewController: UIViewController {
    private let categories = ["City", "State", "Country"]
    private var locations = [
        "City": ["Paris", "Tokyo", "Mumbai", "New York", "Sydney"],
        "State": ["California", "Texas", "Florida", "Gujarat", "Victoria"],
        "Country": ["France", "Japan", "India", "USA", "Australia"],
    ]

    private var score = 0
    private var feedback: String = ""
    private var incorrectAttempts = 0

    private var timer: Timer?
    private var secondsElapsed = 0
    private var moves = 0

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Drag each location to its correct category"
        return label
    }()

    private let statsView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primaryButtonColor
        view.layer.cornerRadius = 12
        return view
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = AppColors.secondaryButtonTextColor
        label.text = "Time: 0s"
        return label
    }()

    private let movesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = AppColors.secondaryButtonTextColor
        label.text = "Moves: 0"
        return label
    }()

    private lazy var categoryStacks: [CategoryStackView] = categories.map { category in
        let stackView = CategoryStackView(title: category)
        stackView.delegate = self
        return stackView
    }

    private let wordsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.cardBackgroundColor
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()

    private let wordsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WordCell.self, forCellWithReuseIdentifier: WordCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "GeoSorter"
        setupUI()
        setupCollectionView()
        populateWords()
        startTimer() // Start the timer when the view loads
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        [subtitleLabel, statsView, wordsContainer].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Create a horizontal stack view for time and moves
        let statsStack = UIStackView(arrangedSubviews: [timeLabel, movesLabel])
        statsStack.axis = .horizontal
        statsStack.distribution = .equalSpacing
        statsStack.spacing = 20
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        statsView.addSubview(statsStack)

        wordsContainer.addSubview(wordsCollectionView)
        wordsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let categoriesStack = UIStackView(arrangedSubviews: categoryStacks)
        categoriesStack.axis = .horizontal
        categoriesStack.distribution = .fillEqually
        categoriesStack.spacing = 12
        categoriesStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(categoriesStack)

        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            statsView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            statsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsView.widthAnchor.constraint(equalToConstant: 240),
            statsView.heightAnchor.constraint(equalToConstant: 60),

            statsStack.centerXAnchor.constraint(equalTo: statsView.centerXAnchor),
            statsStack.centerYAnchor.constraint(equalTo: statsView.centerYAnchor),
            statsStack.leadingAnchor.constraint(equalTo: statsView.leadingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: statsView.trailingAnchor, constant: -20),

            categoriesStack.topAnchor.constraint(equalTo: statsView.bottomAnchor, constant: 24),
            categoriesStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            wordsContainer.topAnchor.constraint(equalTo: categoriesStack.bottomAnchor, constant: 24),
            wordsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            wordsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            wordsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            wordsCollectionView.topAnchor.constraint(equalTo: wordsContainer.topAnchor),
            wordsCollectionView.leadingAnchor.constraint(equalTo: wordsContainer.leadingAnchor),
            wordsCollectionView.trailingAnchor.constraint(equalTo: wordsContainer.trailingAnchor),
            wordsCollectionView.bottomAnchor.constraint(equalTo: wordsContainer.bottomAnchor),
        ])
    }

    private func setupCollectionView() {
        wordsCollectionView.dataSource = self
        wordsCollectionView.delegate = self
        wordsCollectionView.dragDelegate = self
    }

    private func populateWords() {
        // Choose all words for a single round
        var allWords: [(word: String, category: String)] = []
        for (category, words) in locations {
            for word in words {
                allWords.append((word, category))
            }
        }

        allWords.shuffle()

        // Take 5 words from each category for a balanced gameplay
        var selectedWords: [(word: String, category: String)] = []
        var countPerCategory = [String: Int]()

        for word in allWords where selectedWords.count < 10 {
            let category = word.category
            let count = countPerCategory[category] ?? 0

            // Take maximum 5 words per category
            if count < 5 {
                selectedWords.append(word)
                countPerCategory[category] = count + 1
            }
        }

        currentWords = selectedWords
        wordsCollectionView.reloadData()
    }

    private var currentWords: [(word: String, category: String)] = []

    private func updateScore(increase: Bool, feedback: String) {
        if increase {
            // Increase score by 10 points for each correct match
            score += 10

            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            UIView.animate(withDuration: 0.2, animations: {
                self.statsView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.statsView.transform = .identity
                }
            }
        } else {
            incorrectAttempts += 1
            if incorrectAttempts >= 4 {
                showHintAlert()
                incorrectAttempts = 0
            }
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }

        self.feedback = feedback
    }

    private func checkGameStatus() {
        if currentWords.isEmpty {
            gameCompleted()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    @objc private func startNewGame() {
        // Reset game state
        secondsElapsed = 0
        moves = 0
        score = 0
        incorrectAttempts = 0

        // Update UI
        timeLabel.text = "Time: 0s"
        movesLabel.text = "Moves: 0"

        // Clear category stacks
        categoryStacks.forEach { stackView in
            // Remove all arranged subviews from the wordsStack
            for view in stackView.wordsStack.arrangedSubviews {
                stackView.wordsStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }

            // Reset empty state label
            stackView.emptyStateLabel.isHidden = false
        }

        // Populate new words
        populateWords()

        // Start timer
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

        // Provide feedback for a new game
        feedback = "Match locations to their categories"

        // Announce new game started for accessibility
        UIAccessibility.post(notification: .announcement, argument: "New game started. Sort locations into their correct categories.")
    }

    private func gameCompleted() {
        timer?.invalidate()
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
        AudioServicesPlaySystemSound(1025)

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
            completionVC.score = self.score
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

    // Increment moves when a move is made
    private func incrementMoves() {
        moves += 1
        movesLabel.text = "Moves: \(moves)"
    }

    private func showHintAlert() {
        let alertController = UIAlertController(
            title: "Need a hint?",
            message: "Remember: Cities are urban areas (like Tokyo), States are subdivisions of countries (like California), and Countries are sovereign nations (like France).",
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: "Got it", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    private func resetGame() {
        score = 0
        moves = 0
        secondsElapsed = 0
        incorrectAttempts = 0
        timeLabel.text = "Time: 0s"
        movesLabel.text = "Moves: 0"
        updateScore(increase: false, feedback: "Match locations to their categories")

        // Clear category stacks
        categoryStacks.forEach { stackView in
            // Remove all arranged subviews from the wordsStack
            for view in stackView.wordsStack.arrangedSubviews {
                stackView.wordsStack.removeArrangedSubview(view)
                view.removeFromSuperview()
            }

            // Reset empty state label
            stackView.emptyStateLabel.isHidden = false
        }

        populateWords()
    }

    private func removeWord(_ word: String) {
        if let index = currentWords.firstIndex(where: { $0.word == word }) {
            currentWords.remove(at: index)
            wordsCollectionView.reloadData()
            checkGameStatus()
        }
    }

    // Method to verify if a word belongs to a category
    private func isCorrectCategory(word: String, category: String) -> Bool {
        guard let correctCategory = locations.first(where: { $0.value.contains(word) })?.key else {
            return false
        }
        return correctCategory == category
    }
}

// MARK: - UICollectionViewDataSource

extension GeoSorterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentWords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WordCell.identifier, for: indexPath) as? WordCell else {
            return UICollectionViewCell()
        }

        let word = currentWords[indexPath.item].word
        cell.configure(with: word)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GeoSorterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 42) / 3 // 3 columns with spacing
        return CGSize(width: width, height: 50)
    }
}

// MARK: - UICollectionViewDragDelegate

extension GeoSorterViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let word = currentWords[indexPath.item].word
        let itemProvider = NSItemProvider(object: word as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = word
        return [dragItem]
    }
}

// MARK: - CategoryStackViewDelegate

extension GeoSorterViewController: CategoryStackViewDelegate {
    func categoryStackView(_ stackView: CategoryStackView, didReceiveDropWith word: String, category: String) {
        incrementMoves() // Increment moves on each attempt
        let isCorrect = isCorrectCategory(word: word, category: category)

        if isCorrect {
            stackView.addWord(word)

            removeWord(word)
            updateScore(increase: true, feedback: "Correct! \(word) is a \(category).")
        } else {
            // Find correct category
            if let correctCategory = locations.first(where: { $0.value.contains(word) })?.key {
                updateScore(increase: false, feedback: "\(word) is a \(correctCategory), not a \(category).")
            }

            UIView.animate(withDuration: 0.1, animations: {
                stackView.transform = CGAffineTransform(translationX: 10, y: 0)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1, animations: {
                    stackView.transform = CGAffineTransform(translationX: -10, y: 0)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        stackView.transform = .identity
                    }
                })
            })
        }
    }
}

// MARK: - WordCell

class WordCell: UICollectionViewCell {
    static let identifier = "WordCell"

    private let wordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primaryButtonColor
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.iconColor.cgColor
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(wordLabel)

        containerView.translatesAutoresizingMaskIntoConstraints = false
        wordLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            wordLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            wordLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            wordLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 8),
            wordLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8),
        ])
    }

    func configure(with word: String) {
        wordLabel.text = word
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        wordLabel.text = nil
    }
}

#Preview {
    GeoSorterViewController()
}
