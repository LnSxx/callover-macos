//
//  CallCoordinator.swift
//  CalloverDesktop
//
//  Created by Leonid  on 15.05.26.
//

protocol CallCoordinatorProtocol: AnyObject {
    func startCall(
        targetUserId: String,
        type: CallType,
    )
    func acceptCall()
    func declineCall()
    func cancelOutgoingCall()
    func endCurrentCall()
    func sendOffer(sdp: String)
    func sendAnswer(sdp: String)
}

@MainActor
final class CallCoordinator: CallCoordinatorProtocol, RealtimeCallEventHandler {
    private let currentUserId: String
    private let signalingService: SignalingServiceProtocol
    private let callStore: CallStore
    
    init(
        currentUserId: String,
        signalingService: SignalingServiceProtocol,
        callStore: CallStore,
    ) {
        self.currentUserId = currentUserId
        self.signalingService = signalingService
        self.callStore = callStore
    }
    
    func startCall(
        targetUserId: String,
        type: CallType,
    ) {
        callStore.registerOutgoingCall(
            currentUserId: currentUserId,
            targetUserId: targetUserId,
            type: type,
        )
    }
    
    func acceptCall() {
        callStore.markIncomingCallAccepted()
    }
    
    func declineCall() {
        guard let targetUserId = callStore.declineIncomingCall() else {
            return
        }
        
        signalingService.sendAnswer(toUserId: targetUserId, sdp: nil)
    }
    
    func cancelOutgoingCall() {
        guard let targetUserId = callStore.cancelOutgoingCall() else {
            return
        }
        
        signalingService.sendCancel(toUserId: targetUserId)
    }
    
    func endCurrentCall() {
        guard let peerUserId = callStore.markCurrentCallEnded() else {
            return
        }
        
        signalingService.sendEnd(toUserId: peerUserId)
    }
    
    func sendOffer(sdp: String) {
        guard let currentCall = callStore.call else {
            return
        }
        guard currentCall.direction == .outgoing else {
            return
        }
        guard currentCall.status == .calling else {
            return
        }
        
        let targetUserId = currentCall.calleeUserId
        let callType = currentCall.type
        
        signalingService.sendOffer(
            toUserId: targetUserId,
            sdp: sdp,
            type: callType,
        )
    }
    
    func sendAnswer(sdp: String) {
        guard let currentCall = callStore.call else {
            return
        }
        
        guard currentCall.direction == .incoming else {
            return
        }
        
        guard currentCall.status == .connecting else {
            return
        }
        
        signalingService.sendAnswer(
            toUserId: currentCall.callerUserId,
            sdp: sdp
        )
    }
    
    func handle(_ event: RealtimeEvent) {
        switch event {
        case .callOffer(let payload):
            handleIncomingCallOffer(payload)
        case .callAnswer(let payload):
            handleIncomingCallAnswer(payload)
        case .callCancel(let payload):
            handleIncomingCallCancel(payload)
        case .callEnd(let payload):
            handleIncomingCallEnd(payload)
        case .callIceCandidate(let payload):
            handleIncomingCallIceCandidate(payload)
        default:
            break
        }
    }
    
    private func handleIncomingCallOffer(_ payload: CallOfferPayload) {
        if callStore.isBusy {
            signalingService.sendAnswer(
                toUserId: payload.fromUserId,
                sdp: nil,
            )
            return
        }
        callStore.registerIncomingCall(
            currentUserId: currentUserId,
            fromUserId: payload.fromUserId,
            sdp: payload.sdp,
            type: payload.type,
        )
    }
    
    private func handleIncomingCallAnswer(_ payload: CallAnswerPayload) {
        if let sdp = payload.sdp {
            callStore.markOutgoingCallAccepted(
                fromUserId: payload.fromUserId,
                sdp: sdp,
            )
        } else {
            callStore.clearDeclinedOutgoingCall(fromUserId: payload.fromUserId)
        }
        
    }
    
    private func handleIncomingCallCancel(_ payload: CallCancelPayload) {
        callStore.markCallCancelledByPeer(fromUserId: payload.fromUserId)
    }
    
    private func handleIncomingCallEnd(_ payload: CallEndPayload) {
        callStore.markCallEndedByPeer(fromUserId: payload.fromUserId)
    }
    
    private func handleIncomingCallIceCandidate(_ payload: CallIceCandidatePayload) {
        print("Received ICE candidate from \(payload.fromUserId)")
    }
}

class MockCallCoordinator: CallCoordinatorProtocol {
    func startCall(targetUserId: String, type: CallType) {}
    
    func acceptCall() {}
    
    func declineCall() {}
    
    func cancelOutgoingCall() {}
    
    func endCurrentCall() {}
    
    func sendOffer(sdp: String) {}
    
    func sendAnswer(sdp: String) {}
}
