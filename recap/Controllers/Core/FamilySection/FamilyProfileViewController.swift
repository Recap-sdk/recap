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
        imageView.image = UIImage(systemName: "person.circle")
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
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupUI()
        setupTableView()
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

        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        profileImageView.layer.cornerRadius = 60
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 4 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator

        if indexPath.section == 0 {
            let titles = ["Patients", "About App", "Language", "Privacy"]
            cell.textLabel?.text = titles[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "Logout"
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = .boldSystemFont(ofSize: 17)
            cell.backgroundColor = .systemRed
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = .none
            cell.selectionStyle = .default
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
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
        } else if indexPath.section == 1 {
            logoutTapped()
        }
    }

    @objc private func logoutTapped() {
        print("Logged out")
        // Simulate logout and return to login screen
        let loginVC = WelcomeViewController()
        navigationController?.setViewControllers([loginVC], animated: true)
    }
}

#Preview {
    FamilyProfileViewController()
}
