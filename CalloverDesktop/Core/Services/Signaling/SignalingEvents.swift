//
//  SignalingEvents.swift
//  CalloverDesktop
//
//  Created by Leonid  on 14.05.26.
//

import Foundation

enum CallTimeoutReason: String, Decodable {
    case noAnswer = "no_answer"
    case maxDuration = "max_duration"
}

struct CallOfferPayload: Decodable {
    let fromUserId: String
    let sdp: String
    let type: CallType
}

struct CallAnswerPayload: Decodable {
    let fromUserId: String
    let sdp: String
}

struct CallDeclinePayload: Decodable {
    let fromUserId: String
}

struct CallCancelPayload: Decodable {
    let fromUserId: String
}

struct CallEndPayload: Decodable {
    let fromUserId: String
}

struct CallTimeoutPayload: Decodable {
    let roomId: String
    let reason: CallTimeoutReason
}

struct CallIceCandidatePayload: Decodable {
    let fromUserId: String
    let sdp: String
    let sdpMLineIndex: Int32
    let sdpMid: String?
}
