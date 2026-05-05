//
//  RegisterViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation
import Combine

struct RegisterFormState {
    var username = ""
    var password = ""
    var isAcceptedTerms = false
    
    var usernameError: String?
    var passwordError: String?
    var submitError: String?
    var isLoading = false
}

@MainActor
final class RegisterViewModel: ObservableObject {
    @Published var state = RegisterFormState()
    
    private let authService: AuthServiceProtocol
    
    var onLoginSuccess: ((UserProfile) -> Void)?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func toggleTermsAcceptance() {
        state.isAcceptedTerms.toggle()
    }
    
    private func validateForm() -> Bool {
        state.usernameError = nil
        state.passwordError = nil
        state.submitError = nil
        
        if case .failure(let error) = Validator.validateUsername(state.username) {
            state.usernameError = error.errorDescription
        }
        
        if case .failure(let error) = Validator.validatePassword(state.password) {
            state.passwordError = error.errorDescription
        }
        
        if state.usernameError != nil || state.passwordError != nil {
            state.submitError = "Please check provided data"
            return false
        }
        
        if !state.isAcceptedTerms {
            state.submitError = "Make sure you've read Privacy Policy and accepted Terms & Conditions"
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
        case .CONFLICT:
            state.usernameError = "Submitted username is already taken"
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
    
    func submitRegister() {
        guard !state.isLoading else {
            return
        }
        
        guard validateForm() else {
            return
        }
        
        let username = state.username
        let password = state.password
        
        state.isLoading = true
        state.submitError = nil
        
        Task {
            defer { state.isLoading = false }
            
            do {
                let profile = try await authService.signUp(username: username, password: password)
                onLoginSuccess?(profile)
            } catch let error as NetworkError {
                apply(error)
            } catch {
                setDefaultSubmitErrorMessage()
            }
        }
    }
}

