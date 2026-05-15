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
    @StateObject private var callStore = CallStore()
    @StateObject private var realtimeCoordinator: RealtimeSessionCoordinator
    private var callCoordinator: CallCoordinatorProtocol
    
    private let currentUserId: String
    
    init(
        currentUserId: String,
        contactsService: ContactsServiceProtocol,
        realtimeSocketClient: RealtimeSocketClientProtocol,
        signalingService: SignalingServiceProtocol,
    ) {
        self.currentUserId = currentUserId
        
        let contactsViewModel = ContactsViewModel(service: contactsService)
        let presenceStore = PresenceStore()
        let callStore = CallStore()
        let callCoordinator = CallCoordinator(
            currentUserId: currentUserId,
            signalingService: signalingService,
            callStore: callStore,
        )
        
        _contactsViewModel = StateObject(wrappedValue: contactsViewModel)
        _presenceStore = StateObject(wrappedValue: presenceStore)
        _callStore = StateObject(wrappedValue: callStore)
        _realtimeCoordinator = StateObject(
            wrappedValue: RealtimeSessionCoordinator(
                realtimeSocketClient: realtimeSocketClient,
                presenceStore: presenceStore,
                callEventHandler: callCoordinator,
            )
        )
        self.callCoordinator = callCoordinator
    }
    
    var body: some View {
        DashboardView()
            .environmentObject(contactsViewModel)
            .environmentObject(presenceStore)
            .environmentObject(callStore)
            .environment(\.callCoordinator, callCoordinator)
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
