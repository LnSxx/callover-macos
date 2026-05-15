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
        
        self.authService = authServiceInstance
        self.profileService = profileServiceInstance
        self.accountService = accountServiceInstance
        self.contactsService = contactsServiceInstance
        self.realtimeSocketClient = realtimeSocketClientInstance
        self.signalingService = singalingServiceInstance
        
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
        }
    }
}
