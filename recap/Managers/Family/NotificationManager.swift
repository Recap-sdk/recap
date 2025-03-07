//
//  NotificationManager.swift
//  recap
//
//  Created by user@47 on 04/02/25.
//

import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    private let welcomeNotificationKey = "hasReceivedWelcomeNotification"

    func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.askForPermission()
                case .denied:
                    self.showSettingsAlert()
                case .authorized, .provisional, .ephemeral:
                    self.handlePermissionGranted()
                @unknown default:
                    break
                }
            }
        }
    }

    private func askForPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌❌ Notification permission error: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                if granted {
                    print("✅✅ Notification permission granted!!")
                    self.handlePermissionGranted()
                } else {
                    print("❌❌ Notification permission denied!!")
                    self.showSettingsAlert()
                }
            }
        }
    }

    private func showSettingsAlert() {
        guard let topVC = UIApplication.shared.windows.first?.rootViewController else { return }

        let alert = UIAlertController(
            title: "Notifications Required",
            message: "Please enable notifications in Settings to receive reminders.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

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
        content.body = ["It's great to have you here! Let's strengthen your memory.",
                        "Let’s improve your memory with daily exercises!! 🧠🧠",
                        "Your journey to a sharper mind starts today!!"].randomElement()!
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Triggers after 1 second

        let request = UNNotificationRequest(identifier: "welcomeNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌❌ Failed to send welcome notification: \(error.localizedDescription)")
            } else {
                print("✅✅ Welcome notification sent!!")
            }
        }
    }

    func scheduleNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Did you forget to answer questions?? 🧠🧠"
        content.body = "New memory exercises are available!! Strengthen your mind right now."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10800, repeats: true) // Every 3 hours

        let request = UNNotificationRequest(identifier: "questionReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌❌ Failed to schedule recurring notification: \(error.localizedDescription)")
            } else {
                print("✅✅ Recurring notification scheduled every 3 hours!!")
            }
        }
    }
}
