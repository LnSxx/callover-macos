//
//  ActiveIncomingRingingCallDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

struct ActiveIncomingRingingCallDTO: Decodable {
    let type: CallType
    let userId: String
    let peerUserId: String
    let roomId: String
    let status: ActiveRemoteCallStatus
    let createdAt: String
    let acceptedAt: String?
    let remoteDescription: RemoteDescriptionDTO?
}

extension ActiveIncomingRingingCallDTO {
    func toDomain() -> Call {
        return Call(
            callerUserId: peerUserId,
            calleeUserId: userId,
            direction: .incoming,
            status: status.callStatus,
            type: type,
            remoteDescription: remoteDescription?.toSessionDescription()
        )
    }
}
