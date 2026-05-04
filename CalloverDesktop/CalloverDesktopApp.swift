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
    // Services
    private var authService: AuthServiceProtocol
    // Global view models
    @StateObject private var authGateViewModel: AuthGateViewModel
    
    init() {
        let authServiceInstance = AuthService()
        let authGateViewModelInstance = AuthGateViewModel(authService: authServiceInstance)
        
        self.authService = authServiceInstance
        _authGateViewModel = StateObject(wrappedValue: authGateViewModelInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authGateViewModel)
                .environment(\.authService, authService)
        }
    }
}
