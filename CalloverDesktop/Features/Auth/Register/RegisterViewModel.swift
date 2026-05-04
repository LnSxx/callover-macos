//
//  RegisterViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation
internal import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    // CREATE ACCOUNT FIELDS & ERRORS
    // Username field value
    @Published var username = ""
    // Password field value
    @Published var password = ""
    // Terms & conditions acceptance value
    @Published var isAcceptedTerms: Bool = false
    
    // FIELDS VALIDATION ERROR VALUES
    // Username field validation error text
    @Published var usernameValidationErrorText: String? = nil
    // Password field validation error text
    @Published var passwordValidationErrorText: String? = nil
    
    // Submit loading state
    @Published var isLoading = false
    
    // Submit error message
    // Network error or error sent by server
    @Published var submitErrorMessage: String? = nil
    
    // DEPENDENCIES
    private let authService: AuthServiceProtocol
    
    // COMPLETION HANDLERS
    var onLoginSuccess: ((UserProfile) -> Void)?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }
    
    func switchTermsAndConditionAccept() {
        isAcceptedTerms = !isAcceptedTerms
    }
    
    func validateFields() {
        // Clear previous validation errors
        usernameValidationErrorText = nil
        passwordValidationErrorText = nil
        
        // Validate username
        if case .failure(let error) = Validator.validateUsername(username) {
            usernameValidationErrorText = error.errorDescription
        }
        
        // Validate password
        if case .failure(let error) = Validator.validatePassword(password) {
            passwordValidationErrorText = error.errorDescription
        }
        
    }
    
    func submitRegister() {
        validateFields()
        
        guard usernameValidationErrorText == nil &&
        passwordValidationErrorText == nil else {
            submitErrorMessage = "Please check provided data"
            return
        }
        
        guard isAcceptedTerms else {
            submitErrorMessage = "Make sure you've read Privacy Policy and accepted Terms & Conditions"
            return
        }
        
        isLoading = true
        submitErrorMessage = nil
        
        Task {
            do {
                let profile = try await authService.signUp(username: username, password: password)
                isLoading = false
                onLoginSuccess?(profile)
            } catch {
                isLoading = false
                submitErrorMessage = "Error signing up: \(error.localizedDescription)"
            }
        }
    }
}

