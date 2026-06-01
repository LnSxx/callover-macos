//
//  CallLog.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

struct CallLog: Identifiable, Equatable, Hashable {
    let id: String
    let callId: String
    let userId: String
    let peerUserId: String
    let startedAt: Date
    let answeredAt: Date?
    let endedAt: Date?
    let direction: CallDirection
    let type: CallType
    let status: CallLogStatus
    let durationSeconds: Int16?
    let ringingDurationSeconds: Int16?
    let createdAt: Date
}
