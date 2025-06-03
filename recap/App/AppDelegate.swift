//
//  AppDelegate.swift
//  recap
//
//  Created by user@47 on 04/02/25.
//

import Firebase
import FirebaseAnalytics
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Firebase Initialization
        FirebaseApp.configure()
        GIDSignIn.sharedInstance.restorePreviousSignIn()
        Analytics.setAnalyticsCollectionEnabled(true)  //Enable Analytics collection.

        // Set Notification Delegate
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self

        // Only request notification permission if the user hasn't already dismissed the alert
        if !NotificationManager.shared.hasSeenSettingsAlert {
            NotificationManager.shared.requestPermission()
        }

        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(
            name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    func application(
        _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    // Handle Notifications When App is in Foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
            Void
    ) {
        completionHandler([.alert, .sound, .badge])
    }
}
