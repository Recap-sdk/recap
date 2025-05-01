//
//  FamilyViewController_Patient.swift
//  recap
//
//  Created by Diptayan Jash on 05/11/24.
//

import FirebaseAuth
import UIKit

class FamilyViewController_patient: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private var familyMembers: [FamilyMember] = []
    private var collectionView: UICollectionView!
    private let dataFetchManager: DataFetchProtocol = DataFetch()

    // UI elements for no-family-member message
    private let noFamilyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "You haven't added any family members yet.\nShare your Patient ID to add a family member:"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let patientIDLabel: UILabel = {
        let label = UILabel()
        label.text = "Not Set"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
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

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        // Ensure user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user found. Redirecting to login screen.")
            // navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }

        setupUI()
        loadFamilyMembersFromCache()
        fetchPatientID()
        setupRealTimeFamilyMemberUpdates()
        setupNotifications()
        updateUIForFamilyMembers()
    }
    
    private func applyGradientBackground() {
        guard let view = view else { return }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.69, green: 0.88, blue: 0.88, alpha: 1.0).cgColor,
            UIColor(red: 0.94, green: 0.74, blue: 0.80, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func loadFamilyMembersFromCache() {
        familyMembers = dataProtocol.getFamilyMembers()
        updateUIForFamilyMembers()
    }

    private func fetchPatientID() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in.")
            return
        }

        dataFetchManager.fetchUserProfile(userId: userId) { [weak self] userProfile, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching patient ID: \(error.localizedDescription)")
                return
            }
            if let profile = userProfile, let patientID = profile["patientUID"] as? String {
                DispatchQueue.main.async {
                    self.patientIDLabel.text = patientID
                }
            }
        }
    }

    private func fetchFamilyMembersFromFirestore() {
        guard let patientId = Auth.auth().currentUser?.uid else {
            print("Patient not logged in.")
            return
        }

        FirebaseManager.shared.fetchFamilyMembers(for: patientId) { [weak self] members, error in
            guard let self = self else { return }
            if let error = error {
                print("Error fetching family members: \(error.localizedDescription)")
            } else if let members = members {
                self.familyMembers = members
                self.dataProtocol.saveFamilyMembers(members)
                DispatchQueue.main.async {
                    self.updateUIForFamilyMembers()
                }
            }
        }
    }
    
    private func setupRealTimeFamilyMemberUpdates() {
        guard let patientId = Auth.auth().currentUser?.uid else {
            print("Patient not logged in.")
            return
        }

        let familyMemberCollection = FirebaseManager.shared.firestore
            .collection(Constants.FirestoreKeys.usersCollection)
            .document(patientId)
            .collection(Constants.FirestoreKeys.familyMembersCollection)

        familyMemberCollection.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Error listening to changes: \(error.localizedDescription)")
                return
            }
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }

            self.familyMembers = documents.compactMap { doc -> FamilyMember? in
                let data = doc.data()
                return FamilyMember(
                    id: doc.documentID,
                    name: data["name"] as? String ?? "",
                    relationship: data["relationship"] as? String ?? "",
                    phone: data["phone"] as? String ?? "",
                    email: data["email"] as? String ?? "",
                    password: data["password"] as? String ?? "",
                    imageName: data["imageName"] as? String ?? "",
                    imageURL: data["imageURL"] as? String ?? ""
                )
            }

            self.dataProtocol.saveFamilyMembers(self.familyMembers)
            DispatchQueue.main.async {
                self.updateUIForFamilyMembers()
            }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFamilyMemberAdded),
            name: Notification.Name(Constants.NotificationNames.FamilyMemberAdded),
            object: nil
        )
    }

    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        layout.itemSize = CGSize(width: 170, height: 226)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(FamilyMemberCell.self, forCellWithReuseIdentifier: FamilyMemberCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        guard let view = view else { return }
        view.addSubview(collectionView)
        view.addSubview(noFamilyMessageLabel)
        view.addSubview(patientIDLabel)
        view.addSubview(copyButton)

        copyButton.addTarget(self, action: #selector(copyPatientIDTapped), for: .touchUpInside)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            noFamilyMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            noFamilyMessageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noFamilyMessageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            patientIDLabel.topAnchor.constraint(equalTo: noFamilyMessageLabel.bottomAnchor, constant: 10),
            patientIDLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -15),
            
            copyButton.centerYAnchor.constraint(equalTo: patientIDLabel.centerYAnchor),
            copyButton.leadingAnchor.constraint(equalTo: patientIDLabel.trailingAnchor, constant: 8),
            copyButton.widthAnchor.constraint(equalToConstant: 30),
            copyButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        setupFloatingButton()
    }

    @objc private func handleFamilyMemberAdded() {
        print("Handling family member added...")
        loadFamilyMembersFromCache()
        fetchFamilyMembersFromFirestore()
    }

    private func setupFloatingButton() {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = AppColors.iconColor
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

        guard let view = view else { return }
        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 60),
            button.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    @objc private func didTapAdd() {
        print("Add button tapped")
        let addFamily = AddFamilyMemberViewController()
        let navController = UINavigationController(rootViewController: addFamily)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(navController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return familyMembers.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedMember = familyMembers[indexPath.row]
        let detailVC = FamilyMemberDetailViewController(member: selectedMember)
        let navController = UINavigationController(rootViewController: detailVC)

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }

        present(navController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FamilyMemberCell.identifier, for: indexPath) as? FamilyMemberCell else {
            fatalError("Unable to dequeue FamilyMemberCell")
        }
        let member = familyMembers[indexPath.row]
        cell.configure(with: member)
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressToDelete(_:)))
        cell.addGestureRecognizer(longPressGesture)

        return cell
    }

    @objc private func handleLongPressToDelete(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let cell = gesture.view as? UICollectionViewCell,
              let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        let memberToDelete = familyMembers[indexPath.row]

        let alert = UIAlertController(title: "Delete Family Member", message: "Are you sure you want to delete \(memberToDelete.name)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteFamilyMember(memberToDelete, at: indexPath)
        })
        present(alert, animated: true)
    }

    private func deleteFamilyMember(_ member: FamilyMember, at indexPath: IndexPath) {
        guard let patientId = Auth.auth().currentUser?.uid else {
            print("Error: Patient not logged in.")
            return
        }

        FirebaseManager.shared.deleteFamilyMember(for: patientId, memberId: member.id) { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to delete family member: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to delete family member.")
                } else {
                    print("Family member deleted successfully")
                    if indexPath.row < self.familyMembers.count {
                        self.familyMembers.remove(at: indexPath.row)
                        self.dataProtocol.saveFamilyMembers(self.familyMembers)
                        self.collectionView.deleteItems(at: [indexPath])
                        self.updateUIForFamilyMembers()
                    }
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFamilyMembersFromCache()
    }
    
    @objc private func copyPatientIDTapped() {
        if let patientID = patientIDLabel.text, patientID != "Not Set" {
            UIPasteboard.general.string = patientID
            showCopyConfirmation()
        }
    }
    
    private func showCopyConfirmation() {
        let alert = UIAlertController(title: "Copied!", message: "Patient ID copied to clipboard.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    private func updateUIForFamilyMembers() {
        if familyMembers.isEmpty {
            collectionView?.isHidden = true
            noFamilyMessageLabel.isHidden = false
            patientIDLabel.isHidden = false
            copyButton.isHidden = false
        } else {
            collectionView?.isHidden = false
            noFamilyMessageLabel.isHidden = true
            patientIDLabel.isHidden = true
            copyButton.isHidden = true
            collectionView?.reloadData()
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

#Preview {
    FamilyViewController_patient()
}
