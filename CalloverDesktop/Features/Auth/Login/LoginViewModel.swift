//
//  LoginViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation
import Combine

struct LoginFormState {
    var username = ""
    var password = ""
    
    var usernameError: String?
    var passwordError: String?
    var submitError: String?
    var isLoading = false
}

@MainActor
class LoginViewModel: ObservableObject {
    @Published var state = LoginFormState()
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    private func validateForm() -> Bool {
        state.usernameError = nil
        state.passwordError = nil
        state.submitError = nil
        
        if state.username.isEmpty {
            state.usernameError = "Enter username"
        }
        
        if state.password.isEmpty {
            state.passwordError = "Enter password"
        }
        
        if state.usernameError != nil || state.passwordError != nil {
            state.submitError = "Add missing required fields"
            return false
        }
        
        return true
    }
    
    private func apply(_ error: NetworkError) {
        switch error {
        case .errorResponse(let response):
            apply(response)
        default:
            setDefaultSubmitErrorMessage()
        }
    }
    
    private func apply(_ response: ErrorResponse) {
        switch response.code {
        case .AUTHENTICATION_REQUIRED:
            state.usernameError = "Invalid credentials"
        case .VALIDATION_ERROR:
            guard let errors = response.errors else {
                setDefaultSubmitErrorMessage()
                return
            }
            
            applyValidationErrors(errors)
            
        default:
            setDefaultSubmitErrorMessage()
        }
    }
    
    private func applyValidationErrors(_ errors: [ERValidationError]) {
        for error in errors {
            switch error.field {
            case .username:
                state.usernameError = error.code.message
            case .password:
                state.passwordError = error.code.message
            }
        }
    }
    
    private func setDefaultSubmitErrorMessage() {
        state.submitError = "Something went wrong"
    }
    
    func submitLogin() async -> UserProfile? {
        guard !state.isLoading else {
            return nil
        }
        
        guard validateForm() else {
            return nil
        }
        
        let username = state.username
        let password = state.password
        
        state.isLoading = true
        state.submitError = nil
        
        defer { state.isLoading = false }
        do {
            return try await authService.signIn(username: username, password: password)
        } catch let error as NetworkError {
            apply(error)
            return nil
        } catch {
            setDefaultSubmitErrorMessage()
            return nil
        }
    }
}
