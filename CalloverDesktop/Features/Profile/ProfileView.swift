//
//  ProfileView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthGateViewModel
    @State private var didCopyUserId = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Profile")
                .font(.largeTitle)
                .bold()

            switch viewModel.state {
            case .authenticated(let userProfile):
                profileCard(userProfile)

            case .loading:
                ProgressView("Loading profile...")

            case .unauthenticated:
                Text("You are not signed in.")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(32)
    }

    private func profileCard(_ userProfile: UserProfile) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileRow(title: "User ID") {
                HStack(spacing: 8) {
                    Text(String(userProfile.id))
                        .textSelection(.enabled)

                    Button {
                        copyUserId(userProfile.id)
                    } label: {
                        Label(didCopyUserId ? "Copied" : "Copy", systemImage: didCopyUserId ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            ProfileRow(title: "Username") {
                Text(userProfile.username)
                    .textSelection(.enabled)
            }

            if let email = userProfile.email, !email.isEmpty {
                ProfileRow(title: "Email") {
                    Text(email)
                        .textSelection(.enabled)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: 520, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private func copyUserId(_ id: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(String(id), forType: .string)

        didCopyUserId = true

        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            didCopyUserId = false
        }
    }
}

private struct ProfileRow<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)

            content

            Spacer()
        }
    }
}

#Preview {
    let authService = AuthService()
    let profileService = ProfileService()
    let pushTokensService = MockTokensService()
    let accountService = AccountService()
    let coreDataEraser = MockCoreDataEraser()
    
    ProfileView()
        .environmentObject(AuthGateViewModel(
            profileService: profileService,
            pushTokensService: pushTokensService,
            authService: authService,
            accountService: accountService,
            coreDataEraser: coreDataEraser,
        ))
}
