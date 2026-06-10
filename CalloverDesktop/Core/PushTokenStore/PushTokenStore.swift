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
    
    private init() {
        token = UserDefaults.standard.string(forKey: "apns_device_token")
    }
    
    func setToken(_ token: String) {
        self.token = token
        UserDefaults.standard.set(token, forKey: "apns_device_token")
    }
    
    func clear() {
        token = nil
        UserDefaults.standard.removeObject(forKey: "apns_device_token")
    }
}
