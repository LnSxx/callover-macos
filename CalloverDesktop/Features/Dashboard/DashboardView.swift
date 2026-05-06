import SwiftUI

enum DashboardSection: String, CaseIterable, Identifiable {
    case home
    case contacts
    case profile
    case account

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .contacts: "Contacts"
        case .profile: "Profile"
        case .account: "Account"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "teletype.answer"
        case .contacts: "person.crop.rectangle.stack"
        case .profile: "person.crop.circle"
        case .account: "key"
        }
    }
}

struct DashboardView: View {
    @State private var selectedSection: DashboardSection? = .home

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                Section() {
                    sidebarItem(.home)
                    sidebarItem(.contacts)
                }

                Section("Account") {
                    sidebarItem(.profile)
                    sidebarItem(.account)
                }
            }
            .navigationTitle("Callover")
            .frame(minWidth: 220)
        } detail: {
            switch selectedSection ?? .home {
            case .home:
                HomeView()
            case .contacts:
                ContactsView()
            case .profile:
                ProfileView()
            case .account:
                AccountView()
            }
        }
    }

    private func sidebarItem(_ section: DashboardSection) -> some View {
        Label(section.title, systemImage: section.systemImage)
            .tag(section)
    }
}

#Preview {
    let profileService = ProfileService()
    DashboardView()
        .environmentObject(AuthGateViewModel(profileService: profileService))
}
