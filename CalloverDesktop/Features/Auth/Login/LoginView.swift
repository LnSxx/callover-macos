//
//  LoginView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var loginViewModel: LoginViewModel
    @EnvironmentObject private var authGateViewModel: AuthGateViewModel
    
    // Closure
    let onCreateAccountTap: () -> Void
    
    init(authService: AuthServiceProtocol, onCreateAccountTap: @escaping () -> Void) {
        let viewModel = LoginViewModel(authService: authService)
        _loginViewModel = StateObject(wrappedValue:viewModel)
        self.onCreateAccountTap = onCreateAccountTap
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Title with text (example: "Sign in to Callover")
            Text("Sign in to Callover")
                .font(.largeTitle)
            
            // From fields
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 6) {
                    TextField("Username", text: $loginViewModel.state.username)
                        .textFieldStyle(.roundedBorder)
                        .disabled(loginViewModel.state.isLoading)
                    
                    if let error = loginViewModel.state.usernameError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    SecureField("Password", text: $loginViewModel.state.password)
                        .textFieldStyle(.roundedBorder)
                        .disabled(loginViewModel.state.isLoading)
                    
                    if let error = loginViewModel.state.passwordError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                if let error = loginViewModel.state.submitError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: 300)
            
            // Submit button
            Button {
                Task {
                    if let profile = await loginViewModel.submitLogin() {
                        authGateViewModel.authenticate(userProfile: profile)
                    }
                }
            } label: {
                if loginViewModel.state.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 300)
            .disabled(loginViewModel.state.isLoading)
            
            // Suggestion if user don't have an account
            // Contains button that redirects to Register form
            HStack(spacing: 4) {
                Text("Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button("Create one") {
                    onCreateAccountTap()
                }
                .buttonStyle(.link)
            }
            .font(.subheadline)
            
        }.padding(50)
    }
}

#Preview {
    let authService = AuthService()
    let profileService = ProfileService()
    LoginView(authService: authService) {}
        .environmentObject(AuthGateViewModel(profileService: profileService))
}
