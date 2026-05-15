//
//  Call.swift
//  CalloverDesktop
//
//  Created by Leonid  on 14.05.26.
//

struct Call {
    let callerUserId: String
    let calleeUserId: String
    let direction: CallDirection
    var status: CallStatus
    let type: CallType
    var remoteDescription: SessionDescription?
}
