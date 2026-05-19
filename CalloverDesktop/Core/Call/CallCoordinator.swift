//
//  CallCoordinator.swift
//  CalloverDesktop
//
//  Created by Leonid  on 15.05.26.
//

import Combine

protocol CallCoordinatorProtocol: AnyObject {
    func startCall(
        targetUserId: String,
        type: CallType
    )
    func acceptCall()
    func declineCall()
    func cancelOutgoingCall()
    func endCurrentCall()
    func sendOffer(sdp: String)
    func sendAnswer(sdp: String)
}

@MainActor
final class CallCoordinator: ObservableObject, CallCoordinatorProtocol, RealtimeEventHandler {
    private let currentUserId: String
    private let signalingService: SignalingServiceProtocol
    private let callStore: CallStore
    
    init(
        currentUserId: String,
        signalingService: SignalingServiceProtocol,
        callStore: CallStore
    ) {
        self.currentUserId = currentUserId
        self.signalingService = signalingService
        self.callStore = callStore
    }
    
    func startCall(
        targetUserId: String,
        type: CallType
    ) {
        print("[CallCoordinator] startCall received", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId,
            "type": String(describing: type),
            "isBusyBefore": callStore.isBusy,
            "hasCallBefore": callStore.call != nil
        ])
        
        callStore.registerOutgoingCall(
            currentUserId: currentUserId,
            targetUserId: targetUserId,
            type: type
        )
        
        print("[CallCoordinator] startCall completed", [
            "hasCallAfter": callStore.call != nil,
            "callDirection": String(describing: callStore.call?.direction),
            "callStatus": String(describing: callStore.call?.status),
            "calleeUserId": String(describing: callStore.call?.calleeUserId)
        ])
    }
    
    func acceptCall() {
        print("[CallCoordinator] acceptCall received", [
            "currentUserId": currentUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status),
            "callerUserId": String(describing: callStore.call?.callerUserId),
            "callStore": String(describing: ObjectIdentifier(callStore))
        ])
        
        callStore.markIncomingCallAccepted()
        
        print("[CallCoordinator] acceptCall completed", [
            "hasCallAfter": callStore.call != nil,
            "callDirectionAfter": String(describing: callStore.call?.direction),
            "callStatusAfter": String(describing: callStore.call?.status)
        ])
    }
    
    func declineCall() {
        print("[CallCoordinator] declineCall received", [
            "currentUserId": currentUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status),
            "callerUserId": String(describing: callStore.call?.callerUserId)
        ])
        
        guard let targetUserId = callStore.declineIncomingCall() else {
            print("[CallCoordinator] declineCall returned early, no incoming call to decline", [
                "currentUserId": currentUserId,
                "hasCallAfter": callStore.call != nil
            ])
            return
        }
        
        print("[CallCoordinator] declineCall sending empty answer as decline", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId,
            "hasSdp": false
        ])
        
        signalingService.sendDecline(toUserId: targetUserId)
        
        print("[CallCoordinator] declineCall completed", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId,
            "hasCallAfter": callStore.call != nil
        ])
    }
    
    func cancelOutgoingCall() {
        print("[CallCoordinator] cancelOutgoingCall received", [
            "currentUserId": currentUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status),
            "calleeUserId": String(describing: callStore.call?.calleeUserId)
        ])
        
        guard let targetUserId = callStore.cancelOutgoingCall() else {
            print("[CallCoordinator] cancelOutgoingCall returned early, no outgoing call to cancel", [
                "currentUserId": currentUserId,
                "hasCallAfter": callStore.call != nil
            ])
            return
        }
        
        print("[CallCoordinator] cancelOutgoingCall sending cancel", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId
        ])
        
        signalingService.sendCancel(toUserId: targetUserId)
        
        print("[CallCoordinator] cancelOutgoingCall completed", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId,
            "hasCallAfter": callStore.call != nil
        ])
    }
    
    func endCurrentCall() {
        print("[CallCoordinator] endCurrentCall received", [
            "currentUserId": currentUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status),
        ])
        
        guard let peerUserId = callStore.markCurrentCallEnded() else {
            print("[CallCoordinator] endCurrentCall returned early, no current call to end", [
                "currentUserId": currentUserId,
                "hasCallAfter": callStore.call != nil
            ])
            return
        }
        
        print("[CallCoordinator] endCurrentCall sending end", [
            "fromUserId": currentUserId,
            "peerUserId": peerUserId
        ])
        
        signalingService.sendEnd(toUserId: peerUserId)
        
        print("[CallCoordinator] endCurrentCall completed", [
            "fromUserId": currentUserId,
            "peerUserId": peerUserId,
            "hasCallAfter": callStore.call != nil
        ])
    }
    
    func sendOffer(sdp: String) {
        print("[CallCoordinator] sendOffer received", [
            "currentUserId": currentUserId,
            "hasSdp": !sdp.isEmpty,
            "sdpLength": sdp.count,
            "hasCall": callStore.call != nil,
            "callDirection": String(describing: callStore.call?.direction),
            "callStatus": String(describing: callStore.call?.status),
            "calleeUserId": String(describing: callStore.call?.calleeUserId)
        ])
        
        guard let currentCall = callStore.call else {
            print("[CallCoordinator] sendOffer returned early, no current call", [
                "currentUserId": currentUserId
            ])
            return
        }
        
        guard currentCall.direction == .outgoing else {
            print("[CallCoordinator] sendOffer returned early, call is not outgoing", [
                "currentUserId": currentUserId,
                "actualDirection": String(describing: currentCall.direction),
                "expectedDirection": "outgoing"
            ])
            return
        }
        
        guard currentCall.status == .calling else {
            print("[CallCoordinator] sendOffer returned early, call status is not calling", [
                "currentUserId": currentUserId,
                "actualStatus": String(describing: currentCall.status),
                "expectedStatus": "calling"
            ])
            return
        }
        
        let targetUserId = currentCall.calleeUserId
        let callType = currentCall.type
        
        print("[CallCoordinator] sendOffer sending offer", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId,
            "type": String(describing: callType),
            "hasSdp": !sdp.isEmpty,
            "sdpLength": sdp.count
        ])
        
        signalingService.sendOffer(
            toUserId: targetUserId,
            sdp: sdp,
            type: callType
        )
        
        print("[CallCoordinator] sendOffer completed", [
            "fromUserId": currentUserId,
            "targetUserId": targetUserId
        ])
    }
    
    func sendAnswer(sdp: String) {
        print("[CallCoordinator] sendAnswer received", [
            "currentUserId": currentUserId,
            "hasSdp": !sdp.isEmpty,
            "sdpLength": sdp.count,
            "hasCall": callStore.call != nil,
            "callDirection": String(describing: callStore.call?.direction),
            "callStatus": String(describing: callStore.call?.status),
            "callerUserId": String(describing: callStore.call?.callerUserId)
        ])
        
        guard let currentCall = callStore.call else {
            print("[CallCoordinator] sendAnswer returned early, no current call", [
                "currentUserId": currentUserId
            ])
            return
        }
        
        guard currentCall.direction == .incoming else {
            print("[CallCoordinator] sendAnswer returned early, call is not incoming", [
                "currentUserId": currentUserId,
                "actualDirection": String(describing: currentCall.direction),
                "expectedDirection": "incoming"
            ])
            return
        }
        
        guard currentCall.status == .connecting else {
            print("[CallCoordinator] sendAnswer returned early, call status is not connecting", [
                "currentUserId": currentUserId,
                "actualStatus": String(describing: currentCall.status),
                "expectedStatus": "connecting"
            ])
            return
        }
        
        print("[CallCoordinator] sendAnswer sending answer", [
            "fromUserId": currentUserId,
            "targetUserId": currentCall.callerUserId,
            "hasSdp": !sdp.isEmpty,
            "sdpLength": sdp.count
        ])
        
        signalingService.sendAnswer(
            toUserId: currentCall.callerUserId,
            sdp: sdp
        )
        
        print("[CallCoordinator] sendAnswer completed", [
            "fromUserId": currentUserId,
            "targetUserId": currentCall.callerUserId
        ])
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
        print("[CallCoordinator] handleIncomingCallOffer received", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "type": String(describing: payload.type),
            "hasSdp": !payload.sdp.isEmpty,
            "sdpLength": payload.sdp.count,
            "isBusy": callStore.isBusy,
            "hasCallBefore": callStore.call != nil
        ])
        
        if callStore.isBusy {
            print("[CallCoordinator] handleIncomingCallOffer busy, sending empty answer as decline", [
                "currentUserId": currentUserId,
                "fromUserId": payload.fromUserId,
                "hasSdp": false
            ])
            
            signalingService.sendDecline(toUserId: payload.fromUserId)
            
            print("[CallCoordinator] handleIncomingCallOffer completed as busy decline", [
                "currentUserId": currentUserId,
                "fromUserId": payload.fromUserId
            ])
            
            return
        }
        
        callStore.registerIncomingCall(
            currentUserId: currentUserId,
            fromUserId: payload.fromUserId,
            sdp: payload.sdp,
            type: payload.type
        )
        
        print("[CallCoordinator] handleIncomingCallOffer completed, incoming call registered", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallAfter": callStore.call != nil,
            "callDirectionAfter": String(describing: callStore.call?.direction),
            "callStatusAfter": String(describing: callStore.call?.status)
        ])
    }
    
    private func handleIncomingCallAnswer(_ payload: CallAnswerPayload) {
        print("[CallCoordinator] handleIncomingCallAnswer received", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "sdpLength": payload.sdp.count,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status)
        ])
        
        print("[CallCoordinator] handleIncomingCallAnswer marking outgoing call accepted", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasSdp": true,
            "sdpLength": payload.sdp.count
        ])
        
        callStore.markOutgoingCallAccepted(
            fromUserId: payload.fromUserId,
            sdp: payload.sdp
        )
        
        print("[CallCoordinator] handleIncomingCallAnswer completed with SDP", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallAfter": callStore.call != nil,
            "callDirectionAfter": String(describing: callStore.call?.direction),
            "callStatusAfter": String(describing: callStore.call?.status)
        ])
    }
    
    private func handleIncomingCallCancel(_ payload: CallCancelPayload) {
        print("[CallCoordinator] handleIncomingCallCancel received", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status)
        ])
        
        callStore.markCallCancelledByPeer(fromUserId: payload.fromUserId)
        
        print("[CallCoordinator] handleIncomingCallCancel completed", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallAfter": callStore.call != nil,
            "callDirectionAfter": String(describing: callStore.call?.direction),
            "callStatusAfter": String(describing: callStore.call?.status)
        ])
    }
    
    private func handleIncomingCallEnd(_ payload: CallEndPayload) {
        print("[CallCoordinator] handleIncomingCallEnd received", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallBefore": callStore.call != nil,
            "callDirectionBefore": String(describing: callStore.call?.direction),
            "callStatusBefore": String(describing: callStore.call?.status)
        ])
        
        callStore.markCallEndedByPeer(fromUserId: payload.fromUserId)
        
        print("[CallCoordinator] handleIncomingCallEnd completed", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCallAfter": callStore.call != nil,
            "callDirectionAfter": String(describing: callStore.call?.direction),
            "callStatusAfter": String(describing: callStore.call?.status)
        ])
    }
    
    private func handleIncomingCallIceCandidate(_ payload: CallIceCandidatePayload) {
        print("[CallCoordinator] handleIncomingCallIceCandidate received", [
            "currentUserId": currentUserId,
            "fromUserId": payload.fromUserId,
            "hasCandidate": true,
            "hasCall": callStore.call != nil,
            "callDirection": String(describing: callStore.call?.direction),
            "callStatus": String(describing: callStore.call?.status)
        ])
    }
}

class MockCallCoordinator: ObservableObject, CallCoordinatorProtocol {
    func startCall(targetUserId: String, type: CallType) {}
    
    func acceptCall() {}
    
    func declineCall() {}
    
    func cancelOutgoingCall() {}
    
    func endCurrentCall() {}
    
    func sendOffer(sdp: String) {}
    
    func sendAnswer(sdp: String) {}
}
