//
//  OnboardingViewController.swift
//  recap
//
//  Created by Diptayan Jash on 11/02/25.
//

import Foundation
import UIKit

// MARK: - OnboardingPage Model
struct OnboardingPage {
    let image: String  // SF Symbol name
    let title: String
    let description: String
}

// MARK: - OnboardingViewController
class OnboardingViewController: UIViewController {
    
    // MARK: - Properties
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "brain.head.profile",
            title: "Memory Companion",
            description: "Your personal assistant for maintaining and improving memory health"
        ),
        OnboardingPage(
            image: "list.clipboard",
            title: "Daily Questions",
            description: "Answer routine questions and get them verified by family members"
        ),
        OnboardingPage(
            image: "chart.line.uptrend.xyaxis",
            title: "Track Progress",
            description: "Monitor memory improvements with detailed reports and analytics"
        ),
        OnboardingPage(
            image: "gamecontroller",
            title: "Memory Games",
            description: "Engage with fun memory exercises and cognitive games"
        )
    ]
    
    private var currentPage = 0
    
    // MARK: - UI Components
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.delegate = self
        cv.dataSource = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        cv.register(OnboardingCell.self, forCellWithReuseIdentifier: "OnboardingCell")
        return cv
    }()
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .systemBlue
        pc.pageIndicatorTintColor = .systemGray4
        return pc
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        
        button.configuration = configuration
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateButtonTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(continueButton)
        
        pageControl.numberOfPages = pages.count
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            pageControl.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func updateButtonTitle() {
        let isLastPage = currentPage == pages.count - 1
        continueButton.configuration?.title = isLastPage ? "Get Started" : "Continue"
    }
    
    // MARK: - Actions
    @objc private func continueButtonTapped() {
        if currentPage == pages.count - 1 {
            // Mark onboarding as completed
            UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
            dismiss(animated: true) {
                // Call transitionToMainScreen to perform the correct transition
                if let rootVC = UIApplication.shared.windows.first?.rootViewController as? launchScreenViewController {
                    rootVC.transitionToMainScreen()
                }
            }
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = currentPage
            updateButtonTitle()
        }
    }

}

// MARK: - UICollectionView DataSource & Delegate
extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCell", for: indexPath) as! OnboardingCell
        cell.configure(with: pages[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = currentPage
        updateButtonTitle()
    }
}

// MARK: - OnboardingCell
class OnboardingCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemBlue
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        ])
    }
    
    func configure(with page: OnboardingPage) {
        imageView.image = UIImage(systemName: page.image)?.applyingSymbolConfiguration(.init(pointSize: 100))
        titleLabel.text = page.title
        descriptionLabel.text = page.description
    }
}

#Preview {
    OnboardingViewController()
}
