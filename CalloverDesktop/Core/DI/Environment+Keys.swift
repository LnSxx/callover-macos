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
    static let defaultValue: ContactsServiceProtocol = MockContactsService()
}

private struct RealtimeSocketClientKey: EnvironmentKey {
    static let defaultValue: RealtimeSocketClientProtocol = MockRealtimeSocketClient()
}

private struct SignalingServiceKey: EnvironmentKey {
    static let defaultValue: SignalingServiceProtocol = MockSignalingService()
}

private struct CallLogsServiceKey: EnvironmentKey {
    static let defaultValue: CallLogsServiceProtocol = MockCallLogsService()
}

private struct NotificationsServiceKey: EnvironmentKey {
    static let defaultValue: NotificationsServiceProtocol = NotificationsService(
        remoteDataSource: RemoteNotificationsService()
    )
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
    var signalingService: SignalingServiceProtocol {
        get { self[SignalingServiceKey.self] }
        set { self[SignalingServiceKey.self] = newValue }
    }
    var callLogsService: CallLogsServiceProtocol {
        get { self[CallLogsServiceKey.self] }
        set { self[CallLogsServiceKey.self] = newValue }
    }
    var notificationsService: NotificationsServiceProtocol {
        get { self[NotificationsServiceKey.self] }
        set { self[NotificationsServiceKey.self] = newValue }
    }
}
