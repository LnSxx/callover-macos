//
//  AccountView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authGateViewModel: AuthGateViewModel
    
    @State private var isShowingDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Account")
                .font(.largeTitle)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                Text("Current session")
                    .font(.headline)

                Button(role: .cancel) {
                    Task {
                        await authGateViewModel.logout()
                    }
                } label: {
                    Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .controlSize(.large)
            }

            Divider()
                .frame(maxWidth: 520)

            VStack(alignment: .leading, spacing: 12) {
                Text("Delete account")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text("Deleting your account is permanent. Your profile, contacts, sessions, notifications and call history will be removed.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: 520, alignment: .leading)

                Button(role: .destructive) {
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
                .controlSize(.large)
                .confirmationDialog(
                    "Delete Account?",
                    isPresented: $isShowingDeleteConfirmation
                ) {
                    Button("Delete Account", role: .destructive) {
                        Task {
                            await authGateViewModel.deleteAccount()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("There is no way to restore your data back after deleting.")
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(32)
    }
}

#Preview {
    let authService = AuthService()
    let profileService = ProfileService()
    let pushTokensService = MockTokensService()
    let accountService = AccountService()
    let coreDataEraser = MockCoreDataEraser()
    
    AccountView()
        .environmentObject(AuthGateViewModel(
            profileService: profileService,
            pushTokensService: pushTokensService,
            authService: authService,
            accountService: accountService,
            coreDataEraser: coreDataEraser,
        ))
}
