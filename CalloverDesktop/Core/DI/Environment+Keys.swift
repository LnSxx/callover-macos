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

private struct ContactsServiceKey: EnvironmentKey {
    static let defaultValue: ContactsServiceProtocol = ContactsService(
        remoteDataSource: RemoteContactsService(),
        localDataSource: LocalContactsService(
            context: PersistenceController.shared.viewContext
        ),
        syncStateService: SyncStateService(
            context: PersistenceController.shared.viewContext
        ),
    )
}

private struct RealtimeSocketClientKey: EnvironmentKey {
    static let defaultValue: RealtimeSocketClientProtocol = MockRealtimeSocketClient()
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
    var contactsService: ContactsServiceProtocol {
        get { self[ContactsServiceKey.self] }
        set { self[ContactsServiceKey.self] = newValue }
    }
    var realtimeSocketClient: RealtimeSocketClientProtocol {
        get { self[RealtimeSocketClientKey.self] }
        set { self[RealtimeSocketClientKey.self] = newValue }
    }
}
