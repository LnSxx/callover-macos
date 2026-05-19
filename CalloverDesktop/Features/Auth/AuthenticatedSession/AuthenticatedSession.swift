//
//  AuthenticatedSession.swift
//  CalloverDesktop
//
//  Created by Leonid  on 18.05.26.
//
import Combine

@MainActor
final class AuthenticatedSession: ObservableObject {
    let contactsViewModel: ContactsViewModel
    let presenceStore: PresenceStore
    let callStore: CallStore
    let callCoordinator: CallCoordinator
    let realtimeCoordinator: RealtimeSessionCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        currentUserId: String,
        contactsService: ContactsServiceProtocol,
        realtimeSocketClient: RealtimeSocketClientProtocol,
        signalingService: SignalingServiceProtocol
    ) {
        let contactsViewModel = ContactsViewModel(service: contactsService)
        let presenceStore = PresenceStore()
        let callStore = CallStore()
        let callCoordinator = CallCoordinator(
            currentUserId: currentUserId,
            signalingService: signalingService,
            callStore: callStore
        )
        let realtimeCoordinator = RealtimeSessionCoordinator(
            realtimeSocketClient: realtimeSocketClient,
            presenceStore: presenceStore,
            callEventHandler: callCoordinator
        )
        
        self.contactsViewModel = contactsViewModel
        self.presenceStore = presenceStore
        self.callStore = callStore
        self.callCoordinator = callCoordinator
        self.realtimeCoordinator = realtimeCoordinator
        
        contactsViewModel.$contacts
            .removeDuplicates()
            .sink { [weak realtimeCoordinator] contacts in
                realtimeCoordinator?.subscribePresence(for: contacts)
            }
            .store(in: &cancellables)
    }
}
