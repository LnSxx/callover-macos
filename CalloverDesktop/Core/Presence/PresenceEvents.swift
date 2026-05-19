//
//  PresenceEvents.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation

struct PresenceInitialPayload: Decodable {
    let onlineUserIds: [String]
}

struct PresenceUserPayload: Decodable {
    let userId: String
}
