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
    @Published private(set) var isLoggingOut = false
    @Published private(set) var isDeletingAccount = false
    
    private let profileService: ProfileServiceProtocol
    private let pushTokensService: PushTokensServiceProtocol
    private let authService: AuthServiceProtocol
    private let accountService: AccountServiceProtocol
    private let coreDataEraser: CoreDataEraserProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        profileService: ProfileServiceProtocol,
        pushTokensService: PushTokensServiceProtocol,
        authService: AuthServiceProtocol,
        accountService: AccountServiceProtocol,
        coreDataEraser: CoreDataEraserProtocol,
    ) {
        self.profileService = profileService
        self.pushTokensService = pushTokensService
        self.authService = authService
        self.accountService = accountService
        self.coreDataEraser = coreDataEraser
        
        observePushTokenChanges()
        checkAuthenticationStatus()
    }
    
    var isPerformingAccountAction: Bool {
        isLoggingOut || isDeletingAccount
    }
    
    func checkAuthenticationStatus() {
        Task {
            do {
                let userProfile = try await profileService.getProfile()
                state = .authenticated(userProfile)
            } catch {
                state = .unauthenticated
                return
            }
            
            await registerPushTokenIfNeeded()
        }
    }
    
    func authenticate(userProfile: UserProfile) {
        state = .authenticated(userProfile)
        
        Task {
            await registerPushTokenIfNeeded()
        }
    }
    
    func logout() async {
        guard !isPerformingAccountAction else {
            return
        }
        
        isLoggingOut = true
        defer { isLoggingOut = false }
        
        do {
            await unregisterPushToken()
            try await authService.logout()
            try await coreDataEraser.eraseUserData()
            state = .unauthenticated
        } catch {
            print("Failed to log out")
        }
    }
    
    func deleteAccount() async {
        guard !isPerformingAccountAction else {
            return
        }
        
        isDeletingAccount = true
        defer { isDeletingAccount = false }
        
        do {
            try await accountService.deleteAccount()
            try await coreDataEraser.eraseUserData()
            state = .unauthenticated
        } catch {
            print("Failed to delete account")
        }
    }
    
    private func registerPushTokenIfNeeded() async {
        guard let token = PushTokenStore.shared.token else {
            return
        }
        
        do {
            try await pushTokensService.savePushToken(token: token)
        } catch {
            print("Failed to register push token:", error)
        }
    }
    
    private func unregisterPushToken() async {
        guard let token = PushTokenStore.shared.token else {
            return
        }
        
        do {
            try await pushTokensService.deletePushToken(token: token)
        } catch {
            print("Failed to unregister push token:", error)
        }
    }
    
    private func observePushTokenChanges() {
        PushTokenStore.shared.$token
            .compactMap { $0 }
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { @MainActor in
                    guard let self else { return }
                    
                    if case .authenticated = self.state {
                        await self.registerPushTokenIfNeeded()
                    }
                }
            }
            .store(in: &cancellables)
    }
}
