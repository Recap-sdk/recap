//
//  ProfileViewController.swift
//  recap
//
//  Created by Diptayan Jash on 11/11/24.
//
import Foundation
import SDWebImage
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    private var userDetails: [String: Any]?
    private let dataFetchManager: DataFetchProtocol = DataFetch()
    
    private var dataProtocol: FamilyStorageProtocol
    
    init(
        storage: FamilyStorageProtocol = UserDefaultsStorageFamilyMember.shared
    ) {
        dataProtocol = storage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        dataProtocol = UserDefaultsStorageFamilyMember.shared
        super.init(coder: coder)
    }

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.sd_setImage(
            with: URL(string: "https://portfoliodata.djdiptayan.in/profile_pics/dj.png"),
            placeholderImage: UIImage(named: "person.circle"),
            options: [.retryFailed, .highPriority],
            completed: { _, error, _, _ in
                if error != nil {
                    imageView.image = UIImage(named: "person.circle")
                }
            }
        )
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.widthAnchor.constraint(equalToConstant: 95).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 95).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Diptayan Jash"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        return table
    }()

    private var prefetchedQuestions: [rapiMemory]?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupTableView()
        prefetchQuestions()
    }

    private func loadUserProfile() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        dataFetchManager.fetchUserProfile(userId: userId) { [weak self] userProfile, error in
            guard let self = self else { return }

            if let error = error {
                print("Error loading profile: \(error.localizedDescription)")
                self.showAlert(message: "Failed to load profile.")
                return
            }

            if let profile = userProfile {
                print("Profile fetched: \(profile)")

                // Save the profile locally
                UserDefaultsStorageProfile.shared.saveProfile(details: profile, image: nil) { success in
                    if success {
                        self.updateUI(with: profile)
                        self.dataFetchManager.fetchLastMemoryCheck(userId: userId) { [weak self] date in
                            DispatchQueue.main.async {
                                self?.updateMemoryCheckDate(date)
                            }
                        }
                    } else {
                        print("Failed to save profile locally.")
                    }
                }
            }
        }
    }

    private func updateUI(with details: [String: Any]) {
        nameLabel.text = "\(details["firstName"] as? String ?? "Not Set") \(details["lastName"] as? String ?? "Not Set")"

        if let profileImageURL = details["profileImageURL"] as? String, !profileImageURL.isEmpty,
           let url = URL(string: profileImageURL) {
            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "person.circle"))
        } else {
            profileImageView.image = UIImage(named: "person.circle")
        }

        tableView.reloadData()
    }

    private func prefetchQuestions() {
        dataFetchManager.fetchRapidQuestions { [weak self] questions, _ in
            if let questions = questions {
                self?.prefetchedQuestions = questions
            }
        }
    }

    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }

    private func setupUI() {
        [profileImageView, nameLabel, tableView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 95),
            profileImageView.heightAnchor.constraint(equalToConstant: 95),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

//    private func prefetchQuestions() {
//        let dataFetch = DataFetch()
//        dataFetch.fetchRapidQuestions { [weak self] questions, _ in
//            if let questions = questions {
//                self?.prefetchedQuestions = questions
//            }
//        }
//    }
}

// MARK: - UITableViewDelegate & DataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 7
        case 1: return 1
        case 2: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        if indexPath.section == 1 {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
        }
        
        switch indexPath.section {
        case 0:
            let titles = [
                "First Name",
                "Last Name",
                "UID",
                "Date of Birth",
                "Sex",
//                "Age",
                "Blood Type",
                "Stage",
            ]
            UserDefaultsStorageProfile.shared.getProfile()
            let values: [String] = {
                if let details = UserDefaultsStorageProfile.shared.getProfile() {
                    return [
                        details["firstName"] as? String ?? "Not Set",
                        details["lastName"] as? String ?? "Not Set",
                        details["patientUID"] as? String ?? "Not Set",
                        details["dateOfBirth"] as? String ?? "Not Set",
                        details["sex"] as? String ?? "Not Set",
//                        details["age"] as? String ?? "Not Set",
                        details["bloodGroup"] as? String ?? "Not Set",
                        details["stage"] as? String ?? "Not Set",
                    ]
                }
                return Array(repeating: "Not Set", count: 7)
            }()
            
            cell.textLabel?.text = titles[indexPath.row]
            cell.detailTextLabel?.text = values[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.selectionStyle = .none
            
        case 1:
            cell.textLabel?.text = "Memory Check"
            cell.detailTextLabel?.text = "Last check: Fetching"
            cell.imageView?.image = UIImage(systemName: "brain.head.profile")
            cell.imageView?.tintColor = .systemGreen
            cell.selectionStyle = .default
            
        case 2:
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
            cell.backgroundColor = .systemRed
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .default
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            // Memory Check cell tapped
            let memoryCheckVC = MemoryCheckViewController()
            
            // Pass the pre-fetched questions
            memoryCheckVC.preloadedQuestions = prefetchedQuestions
            
            navigationController?.pushViewController(memoryCheckVC, animated: true)
        } else if indexPath.section == 2 {
            let loginVC = PatientLoginViewController()
            loginVC.logoutTapped()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Personal Information"
        case 1: return "Health"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0: return "This information helps us personalize your experience."
        case 1: return "Regular memory checks help track your progress."
        default: return nil
        }
    }

    private func updateMemoryCheckDate(_ date: String) {
        let indexPath = IndexPath(row: 0, section: 1)
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.detailTextLabel?.text = "Last check: \(date)"
        }
    }
}
#Preview {ProfileViewController()}
