//
//  AccountView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject private var authGateViewModel: AuthGateViewModel
    @Environment(\.authService) var authService
    
    @State private var isShowingDeleteConfirmation = false
    
    private func onDeleteAccount() {}

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
                        try await authService.logout()
                        authGateViewModel.logout()
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

                Text("Deleting your account is permanent. Your profile, contacts and local call history will be forever removed.")
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
                        onDeleteAccount()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("There is no way to restore your data back.")
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
    
    AccountView()
        .environmentObject(AuthGateViewModel(profileService: profileService))
        .environment(\.authService, authService)
}
