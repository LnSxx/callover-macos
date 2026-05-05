//
//  AuthGateViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation
import Combine

@MainActor
class AuthGateViewModel: ObservableObject {
    @Published var state: AuthState = .loading
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        Task {
            do {
                let userProfile = try await authService.getProfile()
                state = .authenticated(userProfile)
            } catch {
                state = .unauthenticated
            }
        }
    }
    
    func login(userProfile: UserProfile) {
        state = .authenticated(userProfile)
    }
    
    func logout() {
        state = .unauthenticated
    }
}
