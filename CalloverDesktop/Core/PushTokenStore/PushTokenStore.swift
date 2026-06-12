//
//  PushTokenStore.swift
//  CalloverDesktop
//
//  Created by Leonid  on 10.06.26.
//

import Foundation
import Combine

@MainActor
final class PushTokenStore: ObservableObject {
    static let shared = PushTokenStore()

    @Published private(set) var token: String?

    private let key = "apns_device_token"

    private init() {
        token = UserDefaults.standard.string(forKey: key)
    }

    func setToken(_ token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: key)
    }
}
