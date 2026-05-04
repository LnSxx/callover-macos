//
//  UnauthenticatedView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

enum UnauthenticatedViewState {
    case login
    case register
}

struct UnauthenticatedView: View {
    @Environment(\.authService) var authService
    @State var authenticationType: UnauthenticatedViewState = .login
    
    func switchAuthenticationType() {
        switch authenticationType {
        case .login:
            authenticationType = .register
        case .register:
            authenticationType = .login
        }
    }
    
    var body: some View {
        Group {
            switch authenticationType {
            case .login:
                LoginView(authService: authService, onCreateAccountTap: switchAuthenticationType)
            case .register:
                RegisterView(authService: authService, onSignInTap: switchAuthenticationType)
            }
        }
    }
}
