//
//  CallLogEntityExtension.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

extension CallLogEntity {
    func toDomain() throws -> CallLog {
        guard let id else {
            throw CallLogMappingError.missingRequiredField("id")
        }

        guard let callId else {
            throw CallLogMappingError.missingRequiredField("callId")
        }

        guard let userId else {
            throw CallLogMappingError.missingRequiredField("userId")
        }

        guard let peerUserId else {
            throw CallLogMappingError.missingRequiredField("peerUserId")
        }

        guard let startedAt else {
            throw CallLogMappingError.missingRequiredField("startedAt")
        }

        guard let createdAt else {
            throw CallLogMappingError.missingRequiredField("createdAt")
        }

        guard let directionRaw = direction else {
            throw CallLogMappingError.missingRequiredField("direction")
        }

        guard let typeRaw = type else {
            throw CallLogMappingError.missingRequiredField("type")
        }

        guard let statusRaw = status else {
            throw CallLogMappingError.missingRequiredField("status")
        }

        return CallLog(
            id: id,
            callId: callId,
            userId: userId,
            peerUserId: peerUserId,
            startedAt: startedAt,
            answeredAt: answeredAt,
            endedAt: endedAt,
            direction: try directionRaw.toEnum(CallDirection.self, field: "direction"),
            type: try typeRaw.toEnum(CallType.self, field: "type"),
            status: try statusRaw.toEnum(CallLogStatus.self, field: "status"),
            durationSeconds: durationSeconds,
            ringingDurationSeconds: ringingDurationSeconds,
            createdAt: createdAt
        )
    }
}
