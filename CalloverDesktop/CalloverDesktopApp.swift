//
//  CalloverDesktopApp.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.04.26.
//

import SwiftUI
import CoreData

@main
struct CalloverDesktopApp: App {
    private var authService: AuthServiceProtocol
    private var profileService: ProfileServiceProtocol

    @StateObject private var authGateViewModel: AuthGateViewModel
    
    init() {
        let authServiceInstance = AuthService()
        let profileServiceInstance = ProfileService()
        let authGateViewModelInstance = AuthGateViewModel(profileService: profileServiceInstance)
        
        self.authService = authServiceInstance
        self.profileService = profileServiceInstance
        _authGateViewModel = StateObject(wrappedValue: authGateViewModelInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authGateViewModel)
                .environment(\.authService, authService)
                .environment(\.profileService, profileService)
        }
    }
}
