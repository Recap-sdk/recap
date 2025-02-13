//
//  TabbarFamilyViewController.swift
//  Recap
//
//  Created by admin70 on 05/11/24.
//

import UIKit

class TabbarFamilyViewController: UITabBarController, UITabBarControllerDelegate {
    
    var analyticsService: CoreAnalyticsService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        let grayColor = UIColor(white: 0.95, alpha: 0.85)
        tabBar.backgroundColor = grayColor
        tabBar.barTintColor = grayColor
        tabBar.isTranslucent = true
        
        let tab1 = FamilyViewController()
        let tab2 = ArticleTableViewController()
        
        tab1.title = "Recap"
        tab2.title = "Articles"
        
        tab1.navigationItem.largeTitleDisplayMode = .always
        tab2.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: tab1)
        let nav2 = UINavigationController(rootViewController: tab2)
        
        nav1.tabBarItem = UITabBarItem(title: "Recap", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Articles", image: UIImage(systemName: "doc.text"), selectedImage: UIImage(systemName: "doc.text.fill"))
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        tabBar.tintColor = .label
        setViewControllers([nav1, nav2], animated: true)
        
        analyticsService = CoreAnalyticsService(verifiedUserDocID: Constants.UserDefaultsKeys.verifiedUserDocID)
        analyticsService?.initializeAnalytics()
        
        // Track when the app is opened by family
        analyticsService?.trackAppOpen(isFamily: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

#Preview() {
    TabbarFamilyViewController()
}
