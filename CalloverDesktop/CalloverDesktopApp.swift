//
//  CalloverDesktopApp.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.04.26.
//

import SwiftUI
import CoreData

@main
struct CalloverDesktopApp: App {
    let persistenceController = PersistenceController.shared
    
    private var authService: AuthServiceProtocol
    private var profileService: ProfileServiceProtocol
    private var accountService: AccountServiceProtocol
    private var contactsService: ContactsServiceProtocol
    private var realtimeSocketClient: RealtimeSocketClientProtocol
    private var signalingService: SignalingServiceProtocol
    private var callLogsService: CallLogsServiceProtocol
    private var notificationsService: NotificationsServiceProtocol
    
    @StateObject private var authGateViewModel: AuthGateViewModel
    
    init() {
        let authServiceInstance = AuthService()
        let profileServiceInstance = ProfileService()
        let accountServiceInstance = AccountService()
        let remoteContactsServiceInstance = RemoteContactsService()
        let localContactsServiceInstance = LocalContactsService(context: persistenceController.viewContext)
        let syncStateServiceInstance = SyncStateService(context: persistenceController.viewContext)
        let contactsServiceInstance = ContactsService(
            remoteDataSource: remoteContactsServiceInstance,
            localDataSource: localContactsServiceInstance,
            syncStateService: syncStateServiceInstance,
        )
        let realtimeSocketClientInstance = RealtimeSocketClient(
            baseURL: AppConfig.apiBaseURL
        )
        let singalingServiceInstance = SignalingService(
            realtimeSocketClient: realtimeSocketClientInstance
        )
        let remoteCallLogsServiceInstance = RemoteCallLogsService()
        let localCallLogsServiceInstance = LocalCallLogsService(context: persistenceController.viewContext)
        let callLogsServiceInstance = CallLogsService(
            remoteDataSource: remoteCallLogsServiceInstance,
            localDataSource: localCallLogsServiceInstance
        )
        let remoteNotificationsServiceInstance = RemoteNotificationsService()
        let notificationsServiceInstance = NotificationsService(remoteDataSource: remoteNotificationsServiceInstance)
        
        self.authService = authServiceInstance
        self.profileService = profileServiceInstance
        self.accountService = accountServiceInstance
        self.contactsService = contactsServiceInstance
        self.realtimeSocketClient = realtimeSocketClientInstance
        self.signalingService = singalingServiceInstance
        self.callLogsService = callLogsServiceInstance
        self.notificationsService = notificationsServiceInstance
        
        let authGateViewModelInstance = AuthGateViewModel(profileService: profileServiceInstance)
        _authGateViewModel = StateObject(wrappedValue: authGateViewModelInstance)
    }
    
    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
                .environmentObject(authGateViewModel)
                .environment(\.authService, authService)
                .environment(\.profileService, profileService)
                .environment(\.accountService, accountService)
                .environment(\.contactsService, contactsService)
                .environment(\.realtimeSocketClient, realtimeSocketClient)
                .environment(\.signalingService, signalingService)
                .environment(\.callLogsService, callLogsService)
                .environment(\.notificationsService, notificationsService)
        }
    }
}
