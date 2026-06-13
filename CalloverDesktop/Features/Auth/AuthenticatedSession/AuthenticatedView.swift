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
        callLogsService: CallLogsServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
        currentCallService: CurrentCallServiceProtocol,
    ) {
        _session = StateObject(
            wrappedValue: AuthenticatedSession(
                currentUserId: currentUserId,
                contactsService: contactsService,
                realtimeSocketClient: realtimeSocketClient,
                signalingService: signalingService,
                callLogsService: callLogsService,
                notificationsService: notificationsService,
                currentCallService: currentCallService,
            )
        )
    }
    
    var body: some View {
        DashboardView()
            .environmentObject(session.contactsViewModel)
            .environmentObject(session.presenceStore)
            .environmentObject(session.callStore)
            .environmentObject(session.callMediaStore)
            .environmentObject(session.callCoordinator)
            .environmentObject(session.callHistoryViewModel)
            .environmentObject(session.notificationsViewModel)
            .onAppear {
                session.start()
            }
            .onDisappear {
                session.stop()
            }
    }
}
