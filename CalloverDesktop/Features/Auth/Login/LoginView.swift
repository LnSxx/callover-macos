//
//  LoginView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var loginViewModel: LoginViewModel
    
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
                // Username field
                TextField("Username", text: $loginViewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .disabled(loginViewModel.isLoading)
                // Password field
                SecureField("Password", text: $loginViewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .disabled(loginViewModel.isLoading)
            }
            .frame(maxWidth: 300)
            
            // Submit button
            Button(action: { loginViewModel.login() }) {
                if loginViewModel.isLoading {
                    ProgressView().controlSize(.small)
                } else {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .frame(maxWidth: 300)
            .disabled(loginViewModel.isLoading)
            
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
    LoginView(authService: authService) {}
}
