//
//  RealtimeEvent.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation

enum RealtimeEvent: Decodable {
    case presenceInitial(PresenceInitialPayload)
    case presenceUserOnline(PresenceUserPayload)
    case presenceUserOffline(PresenceUserPayload)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(RealtimeEventType.self, forKey: .type)
        
        switch type {
        case .presenceInitial:
            self = .presenceInitial(
                try container.decode(PresenceInitialPayload.self, forKey: .payload)
            )
            
        case .presenceUserOnline:
            self = .presenceUserOnline(
                try container.decode(PresenceUserPayload.self, forKey: .payload)
            )
            
        case .presenceUserOffline:
            self = .presenceUserOffline(
                try container.decode(PresenceUserPayload.self, forKey: .payload)
            )
            
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unsupported realtime event type"
            )
        }
    }
}
