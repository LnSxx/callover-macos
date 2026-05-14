//
//  HomeViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var contacts: [Contact] = []

    func updateContacts(
        _ allContacts: [Contact],
        onlineUserIds: Set<String>
    ) {
        contacts = allContacts
            .filter { !$0.isBlocked }
            .sorted {
                priority($0, onlineUserIds: onlineUserIds) < priority($1, onlineUserIds: onlineUserIds)
            }
            .prefix(10)
            .map { $0 }
    }

    private func priority(
        _ contact: Contact,
        onlineUserIds: Set<String>
    ) -> Int {
        let isOnline = onlineUserIds.contains(contact.contactUserId)

        if contact.isFavourite && isOnline {
            return 0
        }

        if isOnline {
            return 1
        }

        if contact.isFavourite {
            return 2
        }

        return 3
    }
}
