//
//  FamilyProfileViewController.swift
//  recap
//
//  Created by admin70 on 11/11/24.
//

import UIKit

class FamilyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Diptayan Jash"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white // Set background color to white
        tableView.isScrollEnabled = false // Disable scrolling to keep content fixed
        return tableView
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return button
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupTableView()
        // Load stored family member details
           if let familyMemberData = UserDefaults.standard.dictionary(forKey: Constants.UserDefaultsKeys.familyMemberDetails),
              let name = familyMemberData["name"] as? String {
               nameLabel.text = name
           } else {
               nameLabel.text = "Unknown Family Member"
           }
           // Load profile image from stored URL
           if let imageUrl = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.familyMemberImageURL) {
               profileImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(systemName: "person.circle.fill"))
           }
    }

    private func setupNavigationBar() {
        title = "Profile"
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        navigationItem.rightBarButtonItem = doneButton
    }

    @objc private func doneButtonTapped() {
        dismiss(animated: true)
    }

    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)
        view.addSubview(logoutButton) // Add logout button here

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120), // Increased space for logout button

            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            logoutButton.heightAnchor.constraint(equalToConstant: 50),
        ])

        profileImageView.layer.cornerRadius = 60
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only one section for the list
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // Patients, About App, Language, Privacy
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let titles = ["Patients", "About App", "Language", "Privacy"]
        cell.textLabel?.text = titles[indexPath.row]

        // Ensure white background color
        cell.backgroundColor = .white

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewController: UIViewController
        switch indexPath.row {
        case 0:
            viewController = PatientsViewController()
        case 1:
            viewController = AboutAppViewController()
        case 2:
            viewController = LanguageViewController()
        case 3:
            viewController = PrivacyViewController()
        default:
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func logoutTapped() {
        let familyLoginExtension = FamilyLoginViewController()
        familyLoginExtension.logoutTapped()
    }
}

#Preview {
    FamilyProfileViewController()
}
