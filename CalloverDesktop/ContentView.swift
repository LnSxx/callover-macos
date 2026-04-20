//
//  ContentView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.04.26.
//

import SwiftUI
import CoreData

enum AuthentificationType {
    case signIn
    case signUp
}

struct ContentView: View {
    @State private var authenticationType = AuthentificationType.signIn
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var rememberMe: Bool = false
    @State private var isLoggingIn: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text("Sign in")
                .font(.largeTitle)
                .fontWeight(.semibold)

            // Optional error message
            if let errorMessage = errorMessage, !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.callout)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Fields
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                TextField("name@example.com", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .disableAutocorrection(true)

                Text("Password")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                SecureField("••••••••", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }

            // Remember me + Forgot password
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                Spacer()
                Button("Forgot password?") {
                    // TODO: Handle forgot password
                }
                .buttonStyle(.link)
            }

            // Sign in button
            Button {
                signIn()
            } label: {
                if isLoggingIn {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Sign in")
                        .frame(maxWidth: .infinity)
                }
            }
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.borderedProminent)
            .disabled(!canSubmit || isLoggingIn)

        }
        .padding(24)
        .frame(minWidth: 360)
    }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty
    }

    private func signIn() {
        errorMessage = nil
        guard canSubmit else {
            errorMessage = "Please enter email and password."
            return
        }
        isLoggingIn = true

        // Simulate async login for demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoggingIn = false
            if email.lowercased() == "test@example.com" && password == "password" {
                // Success path
                // TODO: Navigate to the next screen or update app state
            } else {
                errorMessage = "Invalid email or password."
            }
        }
    }
}

#Preview {
    ContentView()
}
