
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

        // Ensure user is logged in
        guard let currentUser = Auth.auth().currentUser else {
            print("No logged-in user found. Redirecting to login screen.")
            // Redirect to login if needed
            // navigationController?.pushViewController(LoginViewController(), animated: true)
            return
        }

        setupUI()
        loadFamilyMembersFromCache()
//        fetchFamilyMembersFromFirestore()
        setupRealTimeFamilyMemberUpdates()
        setupNotifications()
    }

    private func loadFamilyMembersFromCache() {
        familyMembers = dataProtocol.getFamilyMembers()
        collectionView.reloadData()
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
                self.dataProtocol.saveFamilyMembers(members) // Save updated members locally
                DispatchQueue.main.async {
                    self.collectionView.reloadData() // Sync UI
                }
            }
        }
    }
    private func setupRealTimeFamilyMemberUpdates() {
        guard let patientId = Auth.auth().currentUser?.uid else {
            print("Patient not logged in.")
            return
        }

        // Set up a real-time listener
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

            // Save the updated members in cache
            self.dataProtocol.saveFamilyMembers(self.familyMembers)

            DispatchQueue.main.async {
                self.collectionView.reloadData() // Update UI immediately
            }
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFamilyMemberAdded),
            name: Notification.Name("FamilyMemberAdded"),
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

        view.addSubview(collectionView)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        GradientBackground()
        setupFloatingButton()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleFamilyMemberAdded),
            name: Notification.Name("FamilyMemberAdded"),
            object: nil
        )
    }

    @objc private func handleFamilyMemberAdded() {
        print("Handling family member added...")
        loadFamilyMembersFromCache()  // Load instantly after adding a family member
        fetchFamilyMembersFromFirestore()  // Sync in background
    }

    private func GradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemOrange.withAlphaComponent(0.1).cgColor,
            UIColor.systemBackground.cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 0.6)
        gradientLayer.frame = view.bounds

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupFloatingButton() {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)

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
        let AddFamily = AddFamilyMemberViewController()
        let navController = UINavigationController(rootViewController: AddFamily)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        present(navController, animated: true, completion: nil)
    }

    // MARK: - Collection View Data Source

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
        // Add long press gesture to delete
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

        // Show confirmation alert
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

        // Start by deleting the family member from Firebase
        FirebaseManager.shared.deleteFamilyMember(for: patientId, memberId: member.id) { [weak self] error in
            if let error = error {
                print("Failed to delete family member: \(error.localizedDescription)")
                self?.showAlert(title: "Error", message: "Failed to delete family member.")
            } else {
                print("Family member deleted successfully")
                self?.familyMembers.remove(at: indexPath.row)
                self?.dataProtocol.saveFamilyMembers(self?.familyMembers ?? [])
                DispatchQueue.main.async {
                    self?.collectionView.deleteItems(at: [indexPath])
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        loadFamilyMembers()
    }
}

#Preview {
    FamilyViewController_patient()
}
