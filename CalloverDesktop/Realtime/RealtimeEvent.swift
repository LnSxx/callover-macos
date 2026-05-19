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
    
    case callOffer(CallOfferPayload)
    case callAnswer(CallAnswerPayload)
    case callDecline(CallDeclinePayload)
    case callCancel(CallCancelPayload)
    case callEnd(CallEndPayload)
    case callIceCandidate(CallIceCandidatePayload)
    
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
        
        case .callOffer:
            self = .callOffer(
                try container.decode(CallOfferPayload.self, forKey: .payload)
            )
            
        case .callAnswer:
            self = .callAnswer(
                try container.decode(CallAnswerPayload.self, forKey: .payload)
            )
        
        case .callDecline:
            self = .callDecline(
                try container.decode(CallDeclinePayload.self, forKey: .payload)
            )
        
        case .callCancel:
            self = .callCancel(
                try container.decode(CallCancelPayload.self, forKey: .payload)
            )
        
        case .callEnd:
            self = .callEnd(
                try container.decode(CallEndPayload.self, forKey: .payload)
            )
        
        case .callIceCandidate:
            self = .callIceCandidate(
                try container.decode(CallIceCandidatePayload.self, forKey: .payload)
            )
        }
    }
}
