//
//  AuthGate.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct AuthGateView: View {
    @Environment(\.contactsService) var contactsService
    @EnvironmentObject var viewModel: AuthGateViewModel
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                AuthLoadingView()
            case .authenticated(_):
                AuthenticatedView(contactsService: contactsService)
            case .unauthenticated:
                UnauthenticatedView()
            }
        }
    }
}
