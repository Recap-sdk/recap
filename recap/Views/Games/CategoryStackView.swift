import UIKit

protocol CategoryStackViewDelegate: AnyObject {
    func categoryStackView(_ stackView: CategoryStackView, didReceiveDropWith word: String, category: String)
}

class CategoryStackView: UIStackView {
    weak var delegate: CategoryStackViewDelegate?
    let category: String

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        view.layer.borderWidth = 2
        view.layer.borderColor = AppColors.primaryButtonColor.cgColor
        view.layer.shadowColor = AppColors.inverseTextColor.cgColor
        view.layer.shadowOpacity = Float(Constants.FontandColors.defaultshadowOpacity)
        view.layer.shadowOffset = Constants.FontandColors.defaultshadowOffset
        view.layer.shadowRadius = Constants.FontandColors.defaultshadowRadius
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.textColor = AppColors.primaryButtonTextColor
        return label
    }()
    
    // Add scrollView to handle overflow
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    let wordsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        return stack
    }()

    let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Drop items"
        label.font = Constants.FontandColors.descriptionFont
        label.textColor = Constants.FontandColors.descriptionColor
        label.textAlignment = .center
        return label
    }()

    init(title: String) {
        category = title
        super.init(frame: .zero)

        titleLabel.text = title
        setupUI()
        setupDropInteraction()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        axis = .vertical
        spacing = 8
        alignment = .fill

        // Add scrollView to containerView
        containerView.addSubview(scrollView)
        scrollView.addSubview(wordsStack)
        containerView.addSubview(emptyStateLabel)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        wordsStack.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(equalToConstant: 180),
            
            // ScrollView constraints
            scrollView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            scrollView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            scrollView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // WordsStack constraints - note the width matches the scrollView width
            wordsStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            wordsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            wordsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            wordsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            // This ensures the width of the stack matches the scrollView
            wordsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            emptyStateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            emptyStateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            emptyStateLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emptyStateLabel.heightAnchor.constraint(equalToConstant: 40),
        ])

        addArrangedSubview(titleLabel)
        addArrangedSubview(containerView)
    }

    private func setupDropInteraction() {
        let dropInteraction = UIDropInteraction(delegate: self)
        containerView.addInteraction(dropInteraction)
    }

    func addWord(_ word: String) {
        emptyStateLabel.isHidden = true

        let label = createWordLabel(word)
        wordsStack.addArrangedSubview(label)

        label.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            label.transform = .identity
            label.alpha = 1
        })
        
        // Scroll to bottom when a new word is added
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height)
            self.scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }

    private func createWordLabel(_ word: String) -> UILabel {
        let label = UILabel()
        label.text = word
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center
        label.backgroundColor = getRandomColor().withAlphaComponent(0.2)
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.alpha = 0.9
        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 36).isActive = true
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true

        return label
    }

    private func getRandomColor() -> UIColor {
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple]
        return colors.randomElement() ?? .systemBlue
    }
}

extension CategoryStackView: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { items in
            guard let word = items.first as? String else { return }
            self.delegate?.categoryStackView(self, didReceiveDropWith: word, category: self.category)
        }
    }
}

#Preview() {
    CategoryStackView(title: "Fruits")
}
