//
//  RemoteDescriptionDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

import WebRTC

struct RemoteDescriptionDTO: Decodable {
    let type: SessionDescriptionType
    let sdp: String
}

extension RemoteDescriptionDTO {
    func toSessionDescription() -> SessionDescription {
        return SessionDescription(
            type: type,
            sdp: sdp,
        )
    }
}
