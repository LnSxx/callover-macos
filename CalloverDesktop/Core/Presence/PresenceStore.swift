//
//  PresenceStore.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation
import Combine

@MainActor
final class PresenceStore: ObservableObject, RealtimeEventHandler {
    @Published private(set) var onlineUserIds: Set<String> = []
    
    func handle(_ event: RealtimeEvent) {
        switch event {
        case .presenceInitial(let payload):
            onlineUserIds = Set(payload.onlineUserIds)
        case .presenceUserOnline(let payload):
            onlineUserIds.insert(payload.userId)
        case .presenceUserOffline(let payload):
            onlineUserIds.remove(payload.userId)
        default:
            break
        }
    }
    
    func isOnline(_ userId: String) -> Bool {
        onlineUserIds.contains(userId)
    }
    
    func clear() {
        onlineUserIds.removeAll()
    }
}
