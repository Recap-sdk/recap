//
//  TabbarViewController.swift
//  recap
//
//  Created by Diptayan Jash on 03/11/24.
//

import UIKit

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {
    var analyticsService: CoreAnalyticsService?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

        let grayColor = UIColor(white: 0.95, alpha: 0.85)
        
        tabBar.backgroundColor = grayColor
        tabBar.barTintColor = grayColor
        tabBar.isTranslucent = true

        // Setup View Controllers
        let tab1 = HomeViewController()
        let tab2 = FamilyViewController_patient()
        let tab3 = PlayGameViewController()
        
        tab1.title = "Recap"
        tab2.title = "Family"
        tab3.title = "Games"
        
        tab1.navigationItem.largeTitleDisplayMode = .always
        tab2.navigationItem.largeTitleDisplayMode = .always
        tab3.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: tab1)
        let nav2 = UINavigationController(rootViewController: tab2)
        let nav3 = UINavigationController(rootViewController: tab3)
        
        nav1.tabBarItem = UITabBarItem(title: "Recap", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Family", image: UIImage(systemName: "person.2"), selectedImage: UIImage(systemName: "person.2.fill"))
        nav3.tabBarItem = UITabBarItem(title: "Games", image: UIImage(systemName: "gamecontroller"), selectedImage: UIImage(systemName: "gamecontroller.fill"))
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        tabBar.tintColor = .label
        setViewControllers([nav1, nav2, nav3], animated: true)
        
        if let userID = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.verifiedUserDocID) {
                   print("📌 Initializing CoreAnalyticsService with User ID: \(userID)")
                   analyticsService = CoreAnalyticsService(verifiedUserDocID: userID)
                   analyticsService?.initializeAnalytics()
               } else {
                   print("❌ Error: No verifiedUserDocID found in UserDefaults")
               }
           }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview() {
    TabbarViewController()
}
