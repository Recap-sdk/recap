//
//  NotificationManager.swift
//  recap
//
//  Created by s1834 on 04/02/25.
//

import UIKit
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let welcomeNotificationKey = "hasReceivedWelcomeNotification"
    private let notificationPreferenceKey = "userNotificationPreference"
    private let hasSeenSettingsAlertKey = "hasSeenNotificationSettingsAlert"

    var isNotificationsEnabled: Bool {
        return UserDefaults.standard.bool(forKey: notificationPreferenceKey)
    }

    var hasSeenSettingsAlert: Bool {
        return UserDefaults.standard.bool(forKey: hasSeenSettingsAlertKey)
    }

    // Call this method to check if notifications should be requested
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    // Notifications are enabled
                    UserDefaults.standard.set(true, forKey: self.notificationPreferenceKey)
                    self.handlePermissionGranted()
                case .notDetermined:
                    // Wait for user to request notifications explicitly
                    break
                case .denied:
                    // Notifications are denied, respect user preference
                    UserDefaults.standard.set(false, forKey: self.notificationPreferenceKey)
                @unknown default:
                    break
                }
            }
        }
    }

    // Call this when the user explicitly opts in to notifications
    func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.askForPermission()
                case .denied:
                    // Only show settings info if user hasn't dismissed it before
                    if !self.hasSeenSettingsAlert {
                        self.showSettingsInfo()
                    }
                case .authorized, .provisional, .ephemeral:
                    self.handlePermissionGranted()
                @unknown default:
                    break
                }
            }
        }
    }

    private func askForPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            granted, error in
            if let error = error {
                print("❌❌ Notification permission error: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: self.notificationPreferenceKey)

                if granted {
                    print("✅✅ Notification permission granted!!")
                    self.handlePermissionGranted()
                } else {
                    print("❌❌ Notification permission denied!!")
                    // Respect user's choice - don't show settings alert
                }
            }
        }
    }

    private func showSettingsInfo() {
        // Check if user has already seen this alert, don't show it again if they have
        if hasSeenSettingsAlert {
            return
        }

        guard let topVC = UIApplication.shared.windows.first?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Notifications",
            message:
                "You've disabled notifications for this app. You can enable them in Settings to receive reminders, but the app will still function without them.",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Go to Settings", style: .default) { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            })

        alert.addAction(
            UIAlertAction(title: "Continue without notifications", style: .cancel) { _ in
                // Mark that the user has seen this alert so we don't show it again
                UserDefaults.standard.set(true, forKey: self.hasSeenSettingsAlertKey)
            })

        topVC.present(alert, animated: true)
    }

    // Method to show notification benefits and ask for user consent
    func showNotificationBenefits(completion: @escaping (Bool) -> Void) {
        guard let topVC = UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }

        let alert = UIAlertController(
            title: "Enable Notifications?",
            message:
                "Notifications are completely optional, but they can help remind you to practice your memory exercises. Would you like to enable notifications?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "Enable", style: .default) { _ in
                self.requestPermission()
                completion(true)
            })

        alert.addAction(
            UIAlertAction(title: "Not Now", style: .cancel) { _ in
                completion(false)
            })

        topVC.present(alert, animated: true)
    }

    private func handlePermissionGranted() {
        let hasReceivedWelcome = UserDefaults.standard.bool(forKey: self.welcomeNotificationKey)
        if !hasReceivedWelcome {
            self.sendWelcomeNotification()
            UserDefaults.standard.set(true, forKey: self.welcomeNotificationKey)
        }

        self.scheduleNotifications()
    }

    private func sendWelcomeNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Welcome to Recap!! 🎉🎉"
        content.body = [
            "It's great to have you here! Let's strengthen your memory.",
            "Let's improve your memory with daily exercises!! 🧠🧠",
            "Your journey to a sharper mind starts today!!",
        ].randomElement()!
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)  // Triggers after 1 second

        let request = UNNotificationRequest(
            identifier: "welcomeNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌❌ Failed to send welcome notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotifications() {
        // Only schedule if user has granted permission
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                let content = UNMutableNotificationContent()
                content.title = "Did you forget to answer questions?? 🧠🧠"
                content.body =
                    "New memory exercises are available!! Strengthen your mind right now."
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: true)

                let request = UNNotificationRequest(
                    identifier: "questionReminder", content: content, trigger: trigger)

                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print(
                            "❌❌ Failed to schedule recurring notification: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }
    }
}
