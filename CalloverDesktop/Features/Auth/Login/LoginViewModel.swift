//
//  LoginViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let authService: AuthServiceProtocol
    
    var onLoginSuccess: ((UserProfile) -> Void)?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func login() {
        guard !username.isEmpty && !password.isEmpty else {
            errorMessage = "Введите логин и пароль"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let profile = try await authService.signIn(username: username, password: password)
                isLoading = false
                onLoginSuccess?(profile)
            } catch {
                isLoading = false
                errorMessage = "Ошибка входа: \(error.localizedDescription)"
            }
        }
    }
}
