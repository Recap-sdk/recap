////
////  ProfileViewController.swift
////  recap
////
////  Created by Diptayan Jash on 11/11/24.
//
//
//import Foundation
//import SDWebImage
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class ProfileViewController: UIViewController {
//    private var userDetails: [String: Any]?
//    private let dataFetchManager: DataFetchProtocol = DataFetch()
//
//    private var dataProtocol: FamilyStorageProtocol
//
//    init(
//        storage: FamilyStorageProtocol = UserDefaultsStorageFamilyMember.shared
//    ) {
//        dataProtocol = storage
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        dataProtocol = UserDefaultsStorageFamilyMember.shared
//        super.init(coder: coder)
//    }
//
//    private let profileImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "person.circle")
//        imageView.contentMode = .scaleAspectFill
//        imageView.layer.cornerRadius = 10
//        imageView.clipsToBounds = true
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Diptayan Jash"
//        label.font = Constants.FontandColors.titleFont
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let uidCardView: UIView = {
//        let view = UIView()
//        view.backgroundColor = AppColors.primaryButtonColor
//        view.layer.cornerRadius = 10
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private let patientIDLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Patient ID:"
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let uidLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Not Set"
//        label.font = .systemFont(ofSize: 16)
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let copyButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
//        button.tintColor = AppColors.iconColor
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//
//    private let tableView: UITableView = {
//        let table = UITableView(frame: .zero, style: .insetGrouped)
//        table.translatesAutoresizingMaskIntoConstraints = false
//        return table
//    }()
//
//    private var prefetchedQuestions: [rapiMemory]?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        loadUserProfile()
//        view.backgroundColor = .systemBackground
//        setupNavigationBar()
//        setupUI()
//        setupTableView()
//        prefetchQuestions()
//    }
//
//    private func loadUserProfile() {
//        guard let userId = Auth.auth().currentUser?.uid else {
//            print("User not logged in.")
//            return
//        }
//
//        dataFetchManager.fetchUserProfile(userId: userId) { [weak self] userProfile, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error loading profile: \(error.localizedDescription)")
//                self.showAlert(message: "Failed to load profile.")
//                return
//            }
//
//            if let profile = userProfile {
//                print("Profile fetched: \(profile)")
//                UserDefaultsStorageProfile.shared.saveProfile(details: profile, image: nil) { success in
//                    if success {
//                        self.updateUI(with: profile)
//                        self.dataFetchManager.fetchLastMemoryCheck(userId: userId) { [weak self] date in
//                            DispatchQueue.main.async {
//                                self?.updateMemoryCheckDate(date)
//                            }
//                        }
//                    } else {
//                        print("Failed to save profile locally.")
//                    }
//                }
//            }
//        }
//    }
//
//    private func updateUI(with details: [String: Any]) {
//        nameLabel.text = "\(details["firstName"] as? String ?? "Not Set") \(details["lastName"] as? String ?? "Not Set")"
//        uidLabel.text = details["patientUID"] as? String ?? "Not Set"
//
//        if let profileImageURL = details["profileImageURL"] as? String, !profileImageURL.isEmpty,
//           let url = URL(string: profileImageURL) {
//            profileImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "person.circle"))
//        } else {
//            profileImageView.image = UIImage(named: "person.circle")
//        }
//
//        tableView.reloadData()
//    }
//
//    private func prefetchQuestions() {
//        dataFetchManager.fetchRapidQuestions { [weak self] questions, _ in
//            if let questions = questions {
//                self?.prefetchedQuestions = questions
//            }
//        }
//    }
//
//    private func setupNavigationBar() {
//        navigationItem.largeTitleDisplayMode = .never
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
//        navigationItem.rightBarButtonItem = doneButton
//    }
//
//    @objc private func doneButtonTapped() {
//        dismiss(animated: true)
//    }
//
//    private func setupUI() {
//        [profileImageView, nameLabel, uidCardView, tableView].forEach {
//            view.addSubview($0)
//        }
//
//        [patientIDLabel, uidLabel, copyButton].forEach {
//            uidCardView.addSubview($0)
//        }
//
//        copyButton.addTarget(self, action: #selector(copyUIDTapped), for: .touchUpInside)
//
//        profileImageView.layer.cornerRadius = 50
//        profileImageView.layer.masksToBounds = true
//
//        NSLayoutConstraint.activate([
//            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            profileImageView.widthAnchor.constraint(equalToConstant: 95),
//            profileImageView.heightAnchor.constraint(equalToConstant: 95),
//
//            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
//            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//
//            uidCardView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
//            uidCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            uidCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            uidCardView.heightAnchor.constraint(equalToConstant: 44),
//
//            patientIDLabel.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
//            patientIDLabel.leadingAnchor.constraint(equalTo: uidCardView.leadingAnchor, constant: 16),
//
//            uidLabel.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
//            uidLabel.leadingAnchor.constraint(equalTo: patientIDLabel.trailingAnchor, constant: 8),
//            uidLabel.trailingAnchor.constraint(lessThanOrEqualTo: copyButton.leadingAnchor, constant: -8),
//
//            copyButton.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
//            copyButton.trailingAnchor.constraint(equalTo: uidCardView.trailingAnchor, constant: -16),
//            copyButton.widthAnchor.constraint(equalToConstant: 30),
//            copyButton.heightAnchor.constraint(equalToConstant: 30),
//
//            tableView.topAnchor.constraint(equalTo: uidCardView.bottomAnchor, constant: 20),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//
//    private func setupTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//    }
//
//    @objc private func copyUIDTapped() {
//        if let uid = UserDefaultsStorageProfile.shared.getProfile()?["patientUID"] as? String {
//            UIPasteboard.general.string = uid
//            showCopyConfirmation()
//        }
//    }
//
//    private func showCopyConfirmation() {
//        let alert = UIAlertController(title: "Copied!", message: "Patient ID copied to clipboard.", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UITableViewDelegate & DataSource
//
//extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0: return 6
//        case 1: return 1
//        case 2: return 1
//        default: return 0
//        }
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
//
//        if indexPath.section == 1 {
//            cell.accessoryType = .disclosureIndicator
//        } else {
//            cell.accessoryType = .none
//        }
//
//        switch indexPath.section {
//        case 0:
//            let titles = [
//                "First Name",
//                "Last Name",
//                "Date of Birth",
//                "Sex",
//                "Blood Type",
//                "Stage",
//            ]
//            let values: [String] = {
//                if let details = UserDefaultsStorageProfile.shared.getProfile() {
//                    return [
//                        details["firstName"] as? String ?? "Not Set",
//                        details["lastName"] as? String ?? "Not Set",
//                        details["dateOfBirth"] as? String ?? "Not Set",
//                        details["sex"] as? String ?? "Not Set",
//                        details["bloodGroup"] as? String ?? "Not Set",
//                        details["stage"] as? String ?? "Not Set",
//                    ]
//                }
//                return Array(repeating: "Not Set", count: 6)
//            }()
//
//            cell.textLabel?.text = titles[indexPath.row]
//            cell.detailTextLabel?.text = values[indexPath.row]
//            cell.textLabel?.font = .systemFont(ofSize: 17)
//            cell.selectionStyle = .none
//
//        case 1:
//            cell.textLabel?.text = "Memory Check"
//            cell.detailTextLabel?.text = "Last check: Fetching"
//            cell.imageView?.image = UIImage(systemName: "brain.head.profile")
//            cell.imageView?.tintColor = AppColors.iconColor
//            cell.selectionStyle = .default
//
//        case 2:
//            cell.textLabel?.text = "Logout"
//            cell.textLabel?.textColor = .white
//            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
//            cell.backgroundColor = .systemRed
//            cell.textLabel?.textAlignment = .center
//            cell.selectionStyle = .default
//
//        default:
//            break
//        }
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//
//        if indexPath.section == 1 && indexPath.row == 0 {
//            let memoryCheckVC = MemoryCheckViewController()
//            memoryCheckVC.preloadedQuestions = prefetchedQuestions
//            navigationController?.pushViewController(memoryCheckVC, animated: true)
//        } else if indexPath.section == 2 {
//            let loginVC = PatientLoginViewController()
//            loginVC.logoutTapped()
//        }
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0: return "Personal Information"
//        case 1: return "Health"
//        default: return nil
//        }
//    }
//
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        switch section {
//        case 0: return "This information helps us personalize your experience."
//        case 1: return "Regular memory checks help track your progress."
//        default: return nil
//        }
//    }
//
//    private func updateMemoryCheckDate(_ date: String) {
//        let indexPath = IndexPath(row: 0, section: 1)
//        if let cell = tableView.cellForRow(at: indexPath) {
//            cell.detailTextLabel?.text = "Last check: \(date)"
//        }
//    }
//}
//#Preview {ProfileViewController()}

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SDWebImage
import UIKit

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
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Diptayan Jash"
        label.font = Constants.FontandColors.titleFont
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let uidCardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primaryButtonColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let patientIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Patient ID:"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = AppColors.iconColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let uidLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Set"
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppColors.iconColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        button.tintColor = AppColors.iconColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = Constants.ButtonStyle.DefaultButtonFont
        button.backgroundColor = AppColors.iconColor.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = Constants.ButtonStyle.DefaultButtonCornerRadius
        return button
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
                UserDefaultsStorageProfile.shared.saveProfile(details: profile, image: nil) {
                    success in
                    if success {
                        self.updateUI(with: profile)
                        self.dataFetchManager.fetchLastMemoryCheck(userId: userId) {
                            [weak self] date in
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
        nameLabel.text =
            "\(details["firstName"] as? String ?? "Not Set") \(details["lastName"] as? String ?? "Not Set")"
        uidLabel.text = details["patientUID"] as? String ?? "Not Set"

        if let profileImageURL = details["profileImageURL"] as? String, !profileImageURL.isEmpty,
            let url = URL(string: profileImageURL)
        {
            profileImageView.sd_setImage(
                with: url, placeholderImage: UIImage(named: "person.circle"))
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
        let doneButton = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.tintColor = AppColors.iconColor
    }

    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }

    private func setupUI() {
        [profileImageView, nameLabel, uidCardView, tableView, logoutButton].forEach {
            view.addSubview($0)
        }

        [patientIDLabel, uidLabel, copyButton].forEach {
            uidCardView.addSubview($0)
        }

        copyButton.addTarget(self, action: #selector(copyUIDTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 95),
            profileImageView.heightAnchor.constraint(equalToConstant: 95),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            uidCardView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            uidCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            uidCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            uidCardView.heightAnchor.constraint(equalToConstant: 44),

            patientIDLabel.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
            patientIDLabel.leadingAnchor.constraint(
                equalTo: uidCardView.leadingAnchor, constant: 16),

            uidLabel.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
            uidLabel.leadingAnchor.constraint(equalTo: patientIDLabel.trailingAnchor, constant: 8),
            uidLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: copyButton.leadingAnchor, constant: -8),

            copyButton.centerYAnchor.constraint(equalTo: uidCardView.centerYAnchor),
            copyButton.trailingAnchor.constraint(
                equalTo: uidCardView.trailingAnchor, constant: -16),
            copyButton.widthAnchor.constraint(equalToConstant: 30),
            copyButton.heightAnchor.constraint(equalToConstant: 30),

            tableView.topAnchor.constraint(equalTo: uidCardView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: -20),

            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    @objc private func copyUIDTapped() {
        if let uid = UserDefaultsStorageProfile.shared.getProfile()?["patientUID"] as? String {
            UIPasteboard.general.string = uid
            showCopyConfirmation()
        }
    }

    @objc private func logoutTapped() {
        let loginVC = PatientLoginViewController()
        loginVC.logoutTapped()
    }

    private func showCopyConfirmation() {
        let alert = UIAlertController(
            title: "Copied!", message: "Patient ID copied to clipboard.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3  // Personal Information, Health, and Account Management
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 6
        case 1: return 1
        case 2: return 1  // Delete Account option
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
                "Date of Birth",
                "Sex",
                "Blood Type",
                "Stage",
            ]
            let values: [String] = {
                if let details = UserDefaultsStorageProfile.shared.getProfile() {
                    return [
                        details["firstName"] as? String ?? "Not Set",
                        details["lastName"] as? String ?? "Not Set",
                        details["dateOfBirth"] as? String ?? "Not Set",
                        details["sex"] as? String ?? "Not Set",
                        details["bloodGroup"] as? String ?? "Not Set",
                        details["stage"] as? String ?? "Not Set",
                    ]
                }
                return Array(repeating: "Not Set", count: 6)
            }()

            cell.textLabel?.text = titles[indexPath.row]
            cell.detailTextLabel?.text = values[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17)
            cell.selectionStyle = .none

        case 1:
            cell.textLabel?.text = "Memory Check"
            cell.detailTextLabel?.text = "Last check: Fetching"
            cell.imageView?.image = UIImage(systemName: "brain.head.profile")
            cell.imageView?.tintColor = AppColors.iconColor
            cell.selectionStyle = .default

        case 2:
            cell.textLabel?.text = "Delete Account"
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.image = UIImage(systemName: "trash")
            cell.imageView?.tintColor = .systemRed
            cell.accessoryType = .disclosureIndicator
            cell.selectionStyle = .default

        default:
            break
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && indexPath.row == 0 {
            let memoryCheckVC = MemoryCheckViewController()
            memoryCheckVC.preloadedQuestions = prefetchedQuestions
            navigationController?.pushViewController(memoryCheckVC, animated: true)
        } else if indexPath.section == 2 && indexPath.row == 0 {
            // Delete account option tapped
            let deleteAccountVC = DeleteAccountViewController()
            let navController = UINavigationController(rootViewController: deleteAccountVC)
            present(navController, animated: true)
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
#Preview { ProfileViewController() }
