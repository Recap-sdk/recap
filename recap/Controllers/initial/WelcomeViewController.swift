//
//  WelcomeViewController.swift
//  recap
//
//  Created by Diptayan Jash on 05/11/24.
//
//
//import UIKit
//
//class WelcomeViewController: UIViewController {
//
//    // MARK: - UI Components
//    private let logoImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.image = UIImage(named: "recapLogo")
//        return imageView
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Recap"
////        label.font = .systemFont(ofSize: 32, weight: .bold)
//        label.font = UIFont(name: "Pacifico-Regular", size: 45)
//        label.textAlignment = .center
//        return label
//    }()
//
//    private let patientButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Patient", for: .normal)
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
//        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
//        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
//        return button
//    }()
//
//    private let familyButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Family", for: .normal)
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
//        button.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
//        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
//        return button
//    }()
//
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
//        // Add shadow
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        view.layer.shadowRadius = 8
//        view.layer.shadowOpacity = 0.1
//        return view
//    }()
//
//    private let gradientLayer: CAGradientLayer = {
//        let gradient = CAGradientLayer()
//        gradient.colors = [
////            UIColor.systemBlue.cgColor,
////            UIColor.systemPurple.cgColor
//            UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
//            UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor
//
//
//        ]
////        gradient.locations = [0.0, 1.0]
//        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
//        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
//        return gradient
//    }()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupNavigationBar()
//    }
//
//    private func setupNavigationBar() {
//           navigationController?.setNavigationBarHidden(true, animated: false)
//       }
//
//       override func viewWillAppear(_ animated: Bool) {
//           super.viewWillAppear(animated)
//           navigationController?.setNavigationBarHidden(true, animated: animated)
//       }
//
//       override func viewWillDisappear(_ animated: Bool) {
//           super.viewWillDisappear(animated)
//           navigationController?.setNavigationBarHidden(false, animated: animated)
//       }
//
//    // MARK: - Setup UI
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
//
//        // Add gradient background
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
//            UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor
//
//        ]
//        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
//
//        gradientLayer.frame = view.bounds
//        view.layer.insertSublayer(gradientLayer, at: 0)
//
//        // Add subviews
//        view.addSubview(containerView)
//        [logoImageView, titleLabel, patientButton, familyButton].forEach {
//            containerView.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//
//        // Setup constraints
//        NSLayoutConstraint.activate(
//[
//            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            containerView.widthAnchor.constraint(equalToConstant: 350),
//            containerView.heightAnchor.constraint(equalToConstant: 514),
//
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25),
//            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//
//            logoImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
//            logoImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            logoImageView.widthAnchor.constraint(equalToConstant: 150),
//            logoImageView.heightAnchor.constraint(equalToConstant: 180),
//
//            patientButton.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 35),
//            patientButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            patientButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            patientButton.heightAnchor
//                .constraint(
//                    equalToConstant: Constants.ButtonStyle.DefaultButtonHeight
//                ),
//
//            familyButton.topAnchor.constraint(equalTo: patientButton.bottomAnchor, constant: 16),
//            familyButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
//            familyButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
//            familyButton.heightAnchor.constraint(equalToConstant: Constants.ButtonStyle.DefaultButtonHeight)
//        ]
//)
//
//        // Add button targets
//        patientButton.addTarget(self, action: #selector(patientButtonTapped), for: .touchUpInside)
//        familyButton.addTarget(self, action: #selector(familyButtonTapped), for: .touchUpInside)
//    }
//
//    // MARK: - Actions
//    @objc private func patientButtonTapped() {
//           let patientLoginVC = PatientLoginViewController()
//           navigationController?.pushViewController(patientLoginVC, animated: true)
//       }
//
//    @objc private func familyButtonTapped() {
//        print("Family button tapped")
//        let tabBarFamilyVC = FamilyLoginViewController()
//        navigationController?.pushViewController(tabBarFamilyVC, animated: true)
//    }
//
//}
//#Preview{WelcomeViewController()}
import UIKit



class WelcomeViewController: UIViewController {

    

    // MARK: - UI Components

    private let logoImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit

        imageView.image = UIImage(named: "recapLogo")

        return imageView

    }()

    

    private let titleLabel: UILabel = {

        let label = UILabel()

        label.text = "Recap"

        label.font = UIFont(name: "Pacifico-Regular", size: 36) // Use Pacifico font

        label.textAlignment = .center

        label.textColor = AppColors.primaryTextColor

        return label

    }()

    

    private let subtitleLabel: UILabel = {

        let label = UILabel()

        label.text = "Select your role"

        label.font = .systemFont(ofSize: 18, weight: .medium)

        label.textAlignment = .center

        label.textColor = AppColors.primaryTextColor

        return label

    }()

    

    private let patientCard: UIView = {

        let view = UIView()

        view.backgroundColor =  AppColors.cardBackgroundColor

        view.layer.cornerRadius = 16

//        view.layer.shadowColor = UIColor.black.cgColor
//
//        view.layer.shadowOffset = CGSize(width: 0, height: 4)
//
//        view.layer.shadowRadius = 8
//
//        view.layer.shadowOpacity = 0.1

        view.isUserInteractionEnabled = true

        return view

    }()

    

    private let familyCard: UIView = {

        let view = UIView()

        view.backgroundColor =  AppColors.cardBackgroundColor

        view.layer.cornerRadius = 16

//        view.layer.shadowColor = UIColor.black.cgColor
//
//        view.layer.shadowOffset = CGSize(width: 0, height: 4)
//
//        view.layer.shadowRadius = 8
//
//        view.layer.shadowOpacity = 0.1

        view.isUserInteractionEnabled = true

        return view

    }()

    

    private let patientIconImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit

        imageView.image = UIImage(systemName: "heart.fill")

        imageView.tintColor = AppColors.iconColor   // Royal Purple

        return imageView

    }()

    

    private let familyIconImageView: UIImageView = {

        let imageView = UIImageView()

        imageView.contentMode = .scaleAspectFit

        imageView.image = UIImage(systemName: "person.3.fill")

        imageView.tintColor = AppColors.iconColor   // Royal Purple

        return imageView

    }()

    

    private let patientLabel: UILabel = {

        let label = UILabel()

        label.text = "Patient"

        label.font = .systemFont(ofSize: 20, weight: .semibold)

        label.textColor =  AppColors.primaryTextColor   // Royal Purple

        return label

    }()

    

    private let familyLabel: UILabel = {

        let label = UILabel()

        label.text = "Family"

        label.font = .systemFont(ofSize: 20, weight: .semibold)

        label.textColor = AppColors.primaryTextColor

        return label

    }()

    

    private let patientDescriptionLabel: UILabel = {

        let label = UILabel()
        label.text = "Your memories are precious—let’s keep them close, together"

           label.font = .systemFont(ofSize: 14, weight: .regular)

           label.textColor = AppColors.secondaryTextColor // Deep Purple (Light Mode Text)

           label.numberOfLines = 2

           return label

       }()

       

       private let familyDescriptionLabel: UILabel = {

           let label = UILabel()

           label.text = "Monitor and support your loved ones. You can help keep memories alive"

           label.font = .systemFont(ofSize: 14, weight: .regular)

           label.textColor = AppColors.secondaryTextColor // Deep Purple (Light Mode Text)

           label.numberOfLines = 2

           return label

       }()

       

       // MARK: - Lifecycle

       override func viewDidLoad() {

           super.viewDidLoad()

           setupUI()

           setupNavigationBar()

           setupGestures()

           let gradientLayer = AppColors.createAppBackgroundGradientLayer()

               gradientLayer.frame = view.bounds

               view.layer.insertSublayer(gradientLayer, at: 0)

       }

       

       private func setupNavigationBar() {

           navigationController?.setNavigationBarHidden(true, animated: false)

       }

       

       override func viewWillAppear(_ animated: Bool) {

           super.viewWillAppear(animated)

           navigationController?.setNavigationBarHidden(true, animated: animated)

       }

       

       override func viewWillDisappear(_ animated: Bool) {

           super.viewWillDisappear(animated)

           navigationController?.setNavigationBarHidden(false, animated: animated)

       }

       

       // MARK: - Setup UI

    private func setupUI() {
        
        //        view.backgroundColor = UIColor(hex: "#F3E5F5") // Soft Lilac (Background)
        [logoImageView, titleLabel, subtitleLabel, patientCard, familyCard].forEach {

                   view.addSubview($0)

                   $0.translatesAutoresizingMaskIntoConstraints = false

               }

        // Add card content

              [patientIconImageView, patientLabel, patientDescriptionLabel].forEach {

                  patientCard.addSubview($0)

                  $0.translatesAutoresizingMaskIntoConstraints = false

              }

              

              [familyIconImageView, familyLabel, familyDescriptionLabel].forEach {

                  familyCard.addSubview($0)

                  $0.translatesAutoresizingMaskIntoConstraints = false

              }

        // Setup constraints for centering

               NSLayoutConstraint.activate([

                   // Logo ImageView

                   logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                   logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -250),

                   logoImageView.widthAnchor.constraint(equalToConstant: 120),

                   logoImageView.heightAnchor.constraint(equalToConstant: 120),

                   

                   // Title Label
                   titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                
                       titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                       titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 10), // Independent top anchor
                       titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -50), // Bottom constraint with limit, not tied to top
                


                   

                   // Subtitle Label

                   subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                       subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30), // Top padding of 15 from titleLabel
                       subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -25), // Separate bottom constraint with -25 padding
                   

                   // Patient Card

                   patientCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                   patientCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),

                   patientCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

                   patientCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

                   patientCard.heightAnchor.constraint(equalToConstant: 120),

                   

                   // Family Card

                   familyCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                   familyCard.topAnchor.constraint(equalTo: patientCard.bottomAnchor, constant: 30),

                   familyCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),

                   familyCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

                   familyCard.heightAnchor.constraint(equalToConstant: 120),

                   

                   // Patient Card Content

                   patientIconImageView.leadingAnchor.constraint(equalTo: patientCard.leadingAnchor, constant: 24),

                   patientIconImageView.centerYAnchor.constraint(equalTo: patientCard.centerYAnchor),

                   patientIconImageView.widthAnchor.constraint(equalToConstant: 36),

                   patientIconImageView.heightAnchor.constraint(equalToConstant: 36),

                   

                   patientLabel.leadingAnchor.constraint(equalTo: patientIconImageView.trailingAnchor, constant: 16),

                   patientLabel.topAnchor.constraint(equalTo: patientCard.topAnchor, constant: 32),

                   

                   patientDescriptionLabel.leadingAnchor.constraint(equalTo: patientIconImageView.trailingAnchor, constant: 16),

                   patientDescriptionLabel.topAnchor.constraint(equalTo: patientLabel.bottomAnchor, constant: 8),

                   patientDescriptionLabel.trailingAnchor.constraint(equalTo: patientCard.trailingAnchor, constant: -16),

                   

                   // Family Card Content

                   familyIconImageView.leadingAnchor.constraint(equalTo: familyCard.leadingAnchor, constant: 24),

                   familyIconImageView.centerYAnchor.constraint(equalTo: familyCard.centerYAnchor),

                   familyIconImageView.widthAnchor.constraint(equalToConstant: 36),

                   familyIconImageView.heightAnchor.constraint(equalToConstant: 36),

                   

                   familyLabel.leadingAnchor.constraint(equalTo: familyIconImageView.trailingAnchor, constant: 16),

                   familyLabel.topAnchor.constraint(equalTo: familyCard.topAnchor, constant: 32),

                   

                   familyDescriptionLabel.leadingAnchor.constraint(equalTo: familyIconImageView.trailingAnchor, constant: 16),

                   familyDescriptionLabel.topAnchor.constraint(equalTo: familyLabel.bottomAnchor, constant: 8),

                   familyDescriptionLabel.trailingAnchor.constraint(equalTo: familyCard.trailingAnchor, constant: -16)

               ])

           }

           

           private func setupGestures() {

               let patientTapGesture = UITapGestureRecognizer(target: self, action: #selector(patientCardTapped))

               patientCard.addGestureRecognizer(patientTapGesture)

               

               let familyTapGesture = UITapGestureRecognizer(target: self, action: #selector(familyCardTapped))

               familyCard.addGestureRecognizer(familyTapGesture)

           }

           

           // MARK: - Actions

           @objc private func patientCardTapped() {

               let generator = UIImpactFeedbackGenerator(style: .medium)

               generator.impactOccurred()

               

               UIView.animate(withDuration: 0.1, animations: {

                   self.patientCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

               }) { _ in

                   UIView.animate(withDuration: 0.1) {

                       self.patientCard.transform = CGAffineTransform.identity

                   } completion: { _ in

                       let patientLoginVC = PatientLoginViewController()

                       self.navigationController?.pushViewController(patientLoginVC, animated: true)

                   }

               }

           }

           

           @objc private func familyCardTapped() {

               let generator = UIImpactFeedbackGenerator(style: .medium)

               generator.impactOccurred()

               

               UIView.animate(withDuration: 0.1, animations: {

                   self.familyCard.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

               }) { _ in

                   UIView.animate(withDuration: 0.1) {

                       self.familyCard.transform = CGAffineTransform.identity

                   } completion: { _ in

                       let familyLoginVC = FamilyLoginViewController()

                       self.navigationController?.pushViewController(familyLoginVC, animated: true)

                   }

               }

           }

       }
#Preview{WelcomeViewController()}

