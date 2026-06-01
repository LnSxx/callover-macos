//
//  AuthGate.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct AuthGateView: View {
    @Environment(\.contactsService) var contactsService
    @Environment(\.realtimeSocketClient) var realtimeSocketClient
    @Environment(\.signalingService) var signalingService
    @Environment(\.callLogsService) var callLogsService
    @EnvironmentObject var viewModel: AuthGateViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AuthLoadingView()
            case .authenticated(let currentUser):
                AuthenticatedView(
                    currentUserId: currentUser.id,
                    contactsService: contactsService,
                    realtimeSocketClient: realtimeSocketClient,
                    signalingService: signalingService,
                    callLogsService: callLogsService,
                )
            case .unauthenticated:
                UnauthenticatedView()
            }
        }.onChange(of: viewModel.state) { _, state in
            switch state {
            case .authenticated:
                realtimeSocketClient.connect()
            case .unauthenticated:
                realtimeSocketClient.disconnect()
            case .loading:
                break
            }
        }
    }
}
