//
//  SignalingEvents.swift
//  CalloverDesktop
//
//  Created by Leonid  on 14.05.26.
//

import Foundation

struct CallOfferPayload: Decodable {
    let fromUserId: String
    let sdp: String
    let type: CallType
}

struct CallAnswerPayload: Decodable {
    let fromUserId: String
    let sdp: String?
}

struct CallCancelPayload: Decodable {
    let fromUserId: String
}

struct CallEndPayload: Decodable {
    let fromUserId: String
}

struct CallIceCandidatePayload: Decodable {
    let fromUserId: String
    let candidate: String
}
