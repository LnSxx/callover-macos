//
//  AppDelegate.swift
//  CalloverDesktop
//
//  Created by Leonid  on 10.06.26.
//

import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Foundation.Notification) {
        print("AppDelegate did finish launching")
        configureNotifications()
    }

    private func configureNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Notification permission error:", error)
                return
            }

            print("Notification permission granted:", granted)

            guard granted else {
                print("Notification permission denied")
                return
            }

            DispatchQueue.main.async {
                NSApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func application(
        _ application: NSApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("APNs device token:", token)

        Task { @MainActor in
            PushTokenStore.shared.setToken(token)
        }
    }

    func application(
        _ application: NSApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications:", error)
    }
}
