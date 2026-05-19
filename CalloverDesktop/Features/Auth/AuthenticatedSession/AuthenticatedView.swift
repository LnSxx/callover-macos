//
//  AuthenticatedView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var session: AuthenticatedSession
    
    init(
        currentUserId: String,
        contactsService: ContactsServiceProtocol,
        realtimeSocketClient: RealtimeSocketClientProtocol,
        signalingService: SignalingServiceProtocol,
    ) {
        _session = StateObject(
            wrappedValue: AuthenticatedSession(
                currentUserId: currentUserId,
                contactsService: contactsService,
                realtimeSocketClient: realtimeSocketClient,
                signalingService: signalingService
            )
        )
    }
    
    var body: some View {
        DashboardView()
            .environmentObject(session.contactsViewModel)
            .environmentObject(session.presenceStore)
            .environmentObject(session.callStore)
            .environmentObject(session.callCoordinator)
            .onAppear {
                session.realtimeCoordinator.start()
            }
            .onDisappear {
                session.realtimeCoordinator.stop()
            }
    }
}
