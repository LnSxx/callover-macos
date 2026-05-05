//
//  RegisterView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var registerViewModel: RegisterViewModel
    
    let onSignInTap: () -> Void
    
    init(authService: AuthServiceProtocol, onSignInTap: @escaping () -> Void) {
        let viewModel = RegisterViewModel(authService: authService)
        _registerViewModel = StateObject(wrappedValue:viewModel)
        self.onSignInTap = onSignInTap
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title with text (example: "Sign in to Callover")
            Text("Create account in Callover")
                .font(.largeTitle)
            
            // From fields
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Username", text: $registerViewModel.state.username)
                        .textFieldStyle(.roundedBorder)
                        .disabled(registerViewModel.state.isLoading)
                    
                    if let error = registerViewModel.state.usernameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("Password", text: $registerViewModel.state.password)
                        .textFieldStyle(.roundedBorder)
                        .disabled(registerViewModel.state.isLoading)
                    
                    if let error = registerViewModel.state.passwordError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Toggle(isOn: $registerViewModel.state.isAcceptedTerms) {
                    Text("I have read Privacy Policy and accepting Terms & Conditions")
                }
                .disabled(registerViewModel.state.isLoading)
                
                if let error = registerViewModel.state.submitError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: 300)
            
            // Submit button
            Button(action: { registerViewModel.submitRegister() }) {
                if registerViewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 300)
            .disabled(registerViewModel.state.isLoading)
            
            // Suggestion if user don't have an account
            // Contains button that redirects to Register form
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(.secondary)
                
                Button("Sign in") {
                    onSignInTap()
                }
                .buttonStyle(.link)
            }
            .font(.subheadline)
            
        }.padding(50)
    }
}

#Preview {
    let authService = AuthService()
    RegisterView(authService: authService) {}
}
