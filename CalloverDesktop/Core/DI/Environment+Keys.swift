//
//  Environment+Keys.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation
import SwiftUI

private struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: AuthServiceProtocol = AuthService()
}

private struct ProfileServiceKey: EnvironmentKey {
    static let defaultValue: ProfileServiceProtocol = ProfileService()
}

private struct AccountServiceKey: EnvironmentKey {
    static let defaultValue: AccountServiceProtocol = AccountService()
}

extension EnvironmentValues {
    var authService: AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
    var profileService: ProfileServiceProtocol {
        get { self[ProfileServiceKey.self] }
        set { self[ProfileServiceKey.self] = newValue }
    }
    var accountService: AccountServiceProtocol {
        get { self[AccountServiceKey.self] }
        set { self[AccountServiceKey.self] = newValue }
    }
}
