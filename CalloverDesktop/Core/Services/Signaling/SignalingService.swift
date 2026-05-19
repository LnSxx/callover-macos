//
//  SignalingService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 14.05.26.
//

protocol SignalingServiceProtocol {
    func sendOffer(
        toUserId: String,
        sdp: String,
        type: CallType,
    )
    func sendAnswer(
        toUserId: String,
        sdp: String,
    )
    func sendDecline(toUserId: String)
    func sendCancel(toUserId: String)
    func sendEnd(toUserId: String)
    func sendIceCandidate(
        toUserId: String,
        candidate: String,
    )
}

final class SignalingService: SignalingServiceProtocol {
    private let realtimeSocketClient: RealtimeSocketClientProtocol
    
    init(realtimeSocketClient: RealtimeSocketClientProtocol) {
        self.realtimeSocketClient = realtimeSocketClient
    }
    
    func sendOffer(
        toUserId: String,
        sdp: String,
        type: CallType,
    ) {
        realtimeSocketClient.emit(
            "call.offer",
            payload: [
                "toUserId": toUserId,
                "sdp": sdp,
                "type": type,
            ]
        )
    }
    
    func sendAnswer(
        toUserId: String,
        sdp: String,
    ) {
        realtimeSocketClient.emit(
            "call.answer",
            payload: [
                "toUserId": toUserId,
                "sdp": sdp,
            ]
        )
    }
    
    func sendDecline(toUserId: String) {
        realtimeSocketClient.emit(
            "call.decline",
            payload: [
                "toUserId": toUserId,
            ]
        )
    }
    
    func sendCancel(toUserId: String) {
        realtimeSocketClient.emit(
            "call.cancel",
            payload: [
                "toUserId": toUserId,
            ]
        )
    }
    
    func sendEnd(toUserId: String) {
        realtimeSocketClient.emit(
            "call.end",
            payload: [
                "toUserId": toUserId,
            ]
        )
    }
    
    func sendIceCandidate(
        toUserId: String,
        candidate: String
    ) {
        realtimeSocketClient.emit(
            "call.ice-candidate",
            payload: [
                "toUserId": toUserId,
                "candidate": candidate,
            ]
        )
    }
}

final class MockSignalingService: SignalingServiceProtocol {
    func sendOffer(
        toUserId: String,
        sdp: String,
        type: CallType,
    ) {}
    
    func sendAnswer(
        toUserId: String,
        sdp: String,
    ) {}
    
    func sendDecline(toUserId: String) {}
    
    func sendCancel(toUserId: String) {}
    
    func sendEnd(toUserId: String) {}
    
    func sendIceCandidate(
        toUserId: String,
        candidate: String
    ) {}
}
