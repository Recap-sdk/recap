//
//  TabbarFamilyViewController.swift
//  Recap
//
//  Created by khushi on 05/11/24.
//

import UIKit

class TabbarFamilyViewController: UITabBarController, UITabBarControllerDelegate {
    
    private let analyticsService = CoreAnalyticsService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        tabBar.backgroundColor = UIColor(white: 0.95, alpha: 0.85)
        tabBar.isTranslucent = true
        tabBar.tintColor = .label
        
        let nav1 = UINavigationController(rootViewController: FamilyViewController())
        let nav2 = UINavigationController(rootViewController: ArticleTableViewController())
        
        nav1.tabBarItem = UITabBarItem(title: "Recap", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        nav2.tabBarItem = UITabBarItem(title: "Articles", image: UIImage(systemName: "doc.text"), selectedImage: UIImage(systemName: "doc.text.fill"))
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        
        tabBar.tintColor = AppColors.iconColor // Set selected tab color to systemBlue (or your desired color)
                tabBar.unselectedItemTintColor = .gray
        
        setViewControllers([nav1, nav2], animated: true)
        
        analyticsService!.initializeAnalytics()
        analyticsService!.trackAppOpen(isFamily: true)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}

#Preview {
    TabbarFamilyViewController()
}
