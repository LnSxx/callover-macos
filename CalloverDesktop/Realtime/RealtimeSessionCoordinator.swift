//
//  RealtimeSessionCoordinator.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation
import Combine

@MainActor
final class RealtimeSessionCoordinator: ObservableObject {
    private let realtimeSocketClient: RealtimeSocketClientProtocol
    private let presenceStore: PresenceStore

    private var subscribedPresenceUserIds: Set<String> = []

    init(
        realtimeSocketClient: RealtimeSocketClientProtocol,
        presenceStore: PresenceStore
    ) {
        self.realtimeSocketClient = realtimeSocketClient
        self.presenceStore = presenceStore
    }

    func start() {
        realtimeSocketClient.onEvent = { [weak self] event in
            self?.handle(event)
        }
    }

    func stop() {
        realtimeSocketClient.onEvent = nil
        presenceStore.clear()
        subscribedPresenceUserIds.removeAll()
    }

    func subscribePresence(for contacts: [Contact]) {
        let allUserIds = Set(contacts.map(\.contactUserId))
        let newUserIds = allUserIds.subtracting(subscribedPresenceUserIds)

        guard !newUserIds.isEmpty else {
            return
        }

        realtimeSocketClient.emit(
            "presence.subscribe",
            payload: [
                "userIds": Array(newUserIds)
            ]
        )

        subscribedPresenceUserIds.formUnion(newUserIds)
    }

    private func handle(_ event: RealtimeEvent) {
        presenceStore.apply(event)
    }
}
