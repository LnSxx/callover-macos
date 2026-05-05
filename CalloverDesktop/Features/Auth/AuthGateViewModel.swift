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

    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol) {
        self.profileService = profileService
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        Task {
            do {
                let userProfile = try await profileService.getProfile()
                state = .authenticated(userProfile)
            } catch {
                state = .unauthenticated
            }
        }
    }
    
    func authenticate(userProfile: UserProfile) {
        state = .authenticated(userProfile)
    }
    
    func logout() {
        state = .unauthenticated
    }
}
