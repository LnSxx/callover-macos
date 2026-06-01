import SwiftUI

enum DashboardSection: String, CaseIterable, Identifiable {
    case home
    case contacts
    case callHistory
    case profile
    case account
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home: "Home"
        case .contacts: "Contacts"
        case .callHistory: "Call History"
        case .profile: "Profile"
        case .account: "Account"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: "teletype.answer"
        case .contacts: "person.crop.rectangle.stack"
        case .callHistory: "phone.badge.clock"
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
                    sidebarItem(.callHistory)
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
            case .callHistory:
                CallHistoryView()
            case .profile:
                ProfileView()
            case .account:
                AccountView()
            }
        }
        .overlay(alignment: .top) {
            CallView()
        }
    }
    
    private func sidebarItem(_ section: DashboardSection) -> some View {
        Label(section.title, systemImage: section.systemImage)
            .tag(section)
    }
}

#Preview {
    let profileService = ProfileService()
    let contactsService = MockContactsService()
    let callLogsService = MockCallLogsService()
    let contactsViewModel = ContactsViewModel(service: contactsService)
    let presenceStore = PresenceStore()
    let callStore = CallStore()
    let callCoordinator = MockCallCoordinator()

    DashboardView()
        .environmentObject(AuthGateViewModel(profileService: profileService))
        .environmentObject(contactsViewModel)
        .environmentObject(presenceStore)
        .environmentObject(callStore)
        .environmentObject(callCoordinator)
        .environment(\.contactsService, contactsService)
        .environment(\.callLogsService, callLogsService)
        .environment(\.profileService, profileService)
        .environment(\.authService, AuthService())
        .environment(\.accountService, AccountService())
}
