//
//  AuthenticatedView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var contactsViewModel: ContactsViewModel
    @StateObject private var presenceStore = PresenceStore()
    @StateObject private var realtimeCoordinator: RealtimeSessionCoordinator
    
    init(
        contactsService: ContactsServiceProtocol,
        realtimeSocketClient: RealtimeSocketClientProtocol
    ) {
        let contactsViewModel = ContactsViewModel(service: contactsService)
        let presenceStore = PresenceStore()
        
        _contactsViewModel = StateObject(wrappedValue: contactsViewModel)
        _presenceStore = StateObject(wrappedValue: presenceStore)
        _realtimeCoordinator = StateObject(
            wrappedValue: RealtimeSessionCoordinator(
                realtimeSocketClient: realtimeSocketClient,
                presenceStore: presenceStore
            )
        )
    }
    
    var body: some View {
        DashboardView()
            .environmentObject(contactsViewModel)
            .environmentObject(presenceStore)
            .onAppear {
                realtimeCoordinator.start()
                realtimeCoordinator.subscribePresence(for: contactsViewModel.contacts)
            }
            .onChange(of: contactsViewModel.contacts) { _, contacts in
                realtimeCoordinator.subscribePresence(for: contacts)
            }
            .onDisappear {
                realtimeCoordinator.stop()
            }
    }
}
