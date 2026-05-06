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
    private var accountService: AccountServiceProtocol

    @StateObject private var authGateViewModel: AuthGateViewModel
    
    init() {
        let authServiceInstance = AuthService()
        let profileServiceInstance = ProfileService()
        let accountServiceInstance = AccountService()
        
        let authGateViewModelInstance = AuthGateViewModel(profileService: profileServiceInstance)
        
        self.authService = authServiceInstance
        self.profileService = profileServiceInstance
        self.accountService = accountServiceInstance
        
        _authGateViewModel = StateObject(wrappedValue: authGateViewModelInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authGateViewModel)
                .environment(\.authService, authService)
                .environment(\.profileService, profileService)
                .environment(\.accountService, accountService)
        }
    }
}
