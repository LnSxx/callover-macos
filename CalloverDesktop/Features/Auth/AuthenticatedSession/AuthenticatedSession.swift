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
    let callMediaStore: CallMediaStore
    let webRTCClient: WebRTCClient
    let callCoordinator: CallCoordinator
    let realtimeCoordinator: RealtimeSessionCoordinator
    let callHistoryViewModel: CallHistoryViewModel
    let notificationsViewModel: NotificationsViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        currentUserId: String,
        contactsService: ContactsServiceProtocol,
        realtimeSocketClient: RealtimeSocketClientProtocol,
        signalingService: SignalingServiceProtocol,
        callLogsService: CallLogsServiceProtocol,
        notificationsService: NotificationsServiceProtocol,
    ) {
        let contactsViewModel = ContactsViewModel(service: contactsService)
        let presenceStore = PresenceStore()
        let callStore = CallStore()
        let callMediaStore = CallMediaStore()
        let webRTCClient = WebRTCClient(mediaStore: callMediaStore)
        let callCoordinator = CallCoordinator(
            currentUserId: currentUserId,
            signalingService: signalingService,
            callStore: callStore,
            webRTCClient: webRTCClient
        )
        let realtimeCoordinator = RealtimeSessionCoordinator(
            realtimeSocketClient: realtimeSocketClient,
            presenceStore: presenceStore,
            callEventHandler: callCoordinator
        )
        let callHistoryViewModel = CallHistoryViewModel(service: callLogsService)
        let notificationsViewModel = NotificationsViewModel(service: notificationsService)
        
        self.contactsViewModel = contactsViewModel
        self.presenceStore = presenceStore
        self.callStore = callStore
        self.callMediaStore = callMediaStore
        self.webRTCClient = webRTCClient
        self.callCoordinator = callCoordinator
        self.realtimeCoordinator = realtimeCoordinator
        self.callHistoryViewModel = callHistoryViewModel
        self.notificationsViewModel = notificationsViewModel
        
        contactsViewModel.$contacts
            .removeDuplicates()
            .sink { [weak realtimeCoordinator] contacts in
                realtimeCoordinator?.subscribePresence(for: contacts)
            }
            .store(in: &cancellables)
    }
}
