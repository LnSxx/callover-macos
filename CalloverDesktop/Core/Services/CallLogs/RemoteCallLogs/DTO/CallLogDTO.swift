//
//  CallLogDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

struct CallLogDTO: Codable {
    let id: String
    let callId: String
    let userId: String
    let peerUserId: String
    let startedAt: String
    let answeredAt: String?
    let endedAt: String?
    let direction: CallDirection
    let type: CallType
    let status: CallLogStatus
    let durationSeconds: Int16?
    let ringingDurationSeconds: Int16?
    let createdAt: String
}

extension CallLogDTO {
    func toDomain() throws -> CallLog {
        CallLog(
            id: id,
            callId: callId,
            userId: userId,
            peerUserId: peerUserId,
            startedAt: try startedAt.toISODate(),
            answeredAt: try answeredAt?.toISODate(),
            endedAt: try endedAt?.toISODate(),
            direction: direction,
            type: type,
            status: status,
            durationSeconds: durationSeconds,
            ringingDurationSeconds: ringingDurationSeconds,
            createdAt: try createdAt.toISODate()
        )
    }
}
