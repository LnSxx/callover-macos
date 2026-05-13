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
    @EnvironmentObject var viewModel: AuthGateViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AuthLoadingView()
            case .authenticated(_):
                AuthenticatedView(
                    contactsService: contactsService,
                    realtimeSocketClient: realtimeSocketClient,
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
        .onAppear {
            switch viewModel.state {
            case .authenticated:
                realtimeSocketClient.connect()
            default:
                break
            }
        }
    }
}
