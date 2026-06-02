//
//  NotificationCallDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

struct NotificationCallDTO: Codable {
    let callId: String
    let fromUserId: String
    let fromUserName: String?
    let callType: CallType
}

extension NotificationCallDTO {
    func toDomain() -> NotificationCall {
        NotificationCall(
            callId: callId,
            fromUserId: fromUserId,
            fromUserName: fromUserName,
            callType: callType,
        )
    }
}
