//
//  IceCandidateDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

import WebRTC

struct IceCandidateDTO: Decodable {
    let fromUserId: String
    let sdp: String
    let sdpMLineIndex: Int
    let sdpMid: String?
}

extension IceCandidateDTO {
    func toRTCIceCandidate() -> RTCIceCandidate {
        return RTCIceCandidate(
            sdp: sdp,
            sdpMLineIndex: Int32(sdpMLineIndex),
            sdpMid: sdpMid
        )
    }
}
