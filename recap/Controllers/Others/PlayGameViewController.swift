//
//  PlayGameViewController.swift
//  recap
//
//  Created by Diptayan Jash on 06/11/24.
//


import UIKit

class PlayGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        applyGradientBackground()
        title = "Games"

        // Initialize table view
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GamesTableViewCell.self, forCellReuseIdentifier: GamesTableViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = Constants.CardSize.DefaultCardWidth
        // Add table view to view hierarchy
        view.addSubview(tableView)
        
        // Set up constraints
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gamesDemo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GamesTableViewCell.identifier, for: indexPath) as? GamesTableViewCell else {
            fatalError("Unable to dequeue GamesTableViewCell")
        }
        
        let game = gamesDemo[indexPath.row]
        cell.configure(with: game)
        return cell
    }
    
    // MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedGame = gamesDemo[indexPath.row]
        
        if let viewControllerType = NSClassFromString("recap.\(selectedGame.screenName)") as? UIViewController.Type {
            let viewController = viewControllerType.init()
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            print("Error: ViewController \(selectedGame.screenName) not found.")
        }
    }
    
    private func applyGradientBackground() {
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
}

#Preview(){
    PlayGameViewController()
}
