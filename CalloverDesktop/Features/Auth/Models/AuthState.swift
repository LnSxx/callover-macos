//
//  AuthState.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation

enum AuthState: Equatable {
    case loading
    case authenticated(UserProfile)
    case unauthenticated
}
