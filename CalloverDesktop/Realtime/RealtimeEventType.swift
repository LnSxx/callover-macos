//
//  RealtimeEventType.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation

enum RealtimeEventType: String, Decodable {
    case presenceInitial = "presence.initial"
    case presenceUserOnline = "presence.user.online"
    case presenceUserOffline = "presence.user.offline"
    
    case callOffer = "call.offer"
    case callAnswer = "call.answer"
    case callDecline = "call.decline"
    case callCancel = "call.cancel"
    case callEnd = "call.end"
    case callTimeout = "call.timeout"
    case callIceCandidate = "call.ice-candidate"
}
