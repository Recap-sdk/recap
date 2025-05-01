//
//  PatientsViewController.swift
//  recap
//
//  Created by khushi on 27/01/25.
//

import UIKit

class PatientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var userDetails: [String: Any]?
    var prefetchedQuestions: [rapiMemory]?

    private let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "person.circle.fill")
            imageView.contentMode = .scaleAspectFill
            imageView.layer.cornerRadius = 50
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = Constants.CardSize.DefaultCardCornerRadius
        tableView.layer.masksToBounds = true
        tableView.isUserInteractionEnabled = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Patient"
        navigationController?.navigationBar.prefersLargeTitles = false
        setupUI()
        setupTableView()
        fetchPatientDetails()
        updateUIWithData()
        animateContent()
    }

    private func fetchPatientDetails() {
        userDetails = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.patientDetails) as? [String: Any]
    }


    private func updateUIWithData() {
        if let userDetails = userDetails {
            nameLabel.text = "\(userDetails["firstName"] as? String ?? "") \(userDetails["lastName"] as? String ?? "")"

            if let profileImageURL = userDetails["profileImageURL"] as? String, !profileImageURL.isEmpty {
                if let url = URL(string: profileImageURL) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url) {
                            DispatchQueue.main.async {
                                self.profileImageView.image = UIImage(data: data)
                            }
                        }
                    }
                }
            }
            tableView.reloadData()
        }
    }

    @objc private func doneButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupUI() {
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.accessoryType = .none

        let titles = ["First Name", "Last Name", "Date of Birth", "Sex", "Blood Type"]
        let values = [
            userDetails?["firstName"] as? String ?? "Not Set",
            userDetails?["lastName"] as? String ?? "Not Set",
            userDetails?["dateOfBirth"] as? String ?? "Not Set",
            userDetails?["sex"] as? String ?? "Not Set",
            userDetails?["bloodGroup"] as? String ?? "Not Set"
        ]

        cell.textLabel?.text = titles[indexPath.row]
        cell.detailTextLabel?.text = values[indexPath.row]

        if values[indexPath.row] == "Not Set" {
            cell.detailTextLabel?.textColor = .systemGray
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    private func animateContent() {
        let views = [profileImageView, nameLabel, tableView]
            
        views.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            
            UIView.animate(
                withDuration: 0.6,
                delay: Double(index) * 0.2,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseOut
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
}

#Preview {
    PatientsViewController()
}
