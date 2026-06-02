//
//  NotificationCall.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

struct NotificationCall: Equatable, Hashable {
    let callId: String
    let fromUserId: String
    let fromUserName: String?
    let callType: CallType
}
