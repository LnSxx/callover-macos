//
//  CallCoordinator.swift
//  CalloverDesktop
//
//  Created by Leonid  on 15.05.26.
//

import Combine
import WebRTC

protocol CallCoordinatorProtocol: AnyObject {
    func startCall(
        targetUserId: String,
        type: CallType
    )
    func acceptCall()
    func declineCall()
    func cancelOutgoingCall()
    func endCurrentCall()
}

@MainActor
final class CallCoordinator: ObservableObject, CallCoordinatorProtocol, RealtimeEventHandler {
    private let currentUserId: String
    private let signalingService: SignalingServiceProtocol
    private let callStore: CallStore
    private let webRTCClient: WebRTCClient
    
    init(
        currentUserId: String,
        signalingService: SignalingServiceProtocol,
        callStore: CallStore,
        webRTCClient: WebRTCClient,
    ) {
        self.currentUserId = currentUserId
        self.signalingService = signalingService
        self.callStore = callStore
        
        self.webRTCClient = webRTCClient
        
        self.webRTCClient.onIceCandidate = { [weak self] candidate in
            self?.sendIceCandidate(candidate)
        }
    }
    
    func startCall(
        targetUserId: String,
        type: CallType
    ) {
        Task {
            do {
                try await webRTCClient.startLocalMedia()
                webRTCClient.createPeerConnection()
                
                callStore.registerOutgoingCall(
                    currentUserId: currentUserId,
                    targetUserId: targetUserId,
                    type: type
                )
                
                let offer = try await webRTCClient.createOffer()
                
                signalingService.sendOffer(
                    toUserId: targetUserId,
                    sdp: offer.sdp,
                    type: type,
                )
            } catch {
                callStore.reset()
                webRTCClient.close()
            }
        }
    }
    
    func acceptCall() {
        guard let call = callStore.call else { return }
        
        Task {
            do {
                callStore.markIncomingCallAccepted()
                
                try await webRTCClient.startLocalMedia()
                webRTCClient.createPeerConnection()
                
                guard let sdp = call.remoteDescription?.sdp else {
                    callStore.reset()
                    webRTCClient.close()
                    return
                }
                
                let remoteOffer = RTCSessionDescription(
                    type: .offer,
                    sdp: sdp
                )
                
                try await webRTCClient.setRemoteDescription(remoteOffer)
                
                let answer = try await webRTCClient.createAnswer()
                
                signalingService.sendAnswer(
                    toUserId: call.callerUserId,
                    sdp: answer.sdp
                )
            } catch {
                callStore.reset()
                webRTCClient.close()
            }
        }
    }
    
    func declineCall() {
        guard let targetUserId = callStore.declineIncomingCall() else {
            return
        }
        
        signalingService.sendDecline(toUserId: targetUserId)
        webRTCClient.close()
    }
    
    func cancelOutgoingCall() {
        guard let targetUserId = callStore.cancelOutgoingCall() else {
            return
        }
        
        signalingService.sendCancel(toUserId: targetUserId)
        webRTCClient.close()
    }
    
    func endCurrentCall() {
        guard let peerUserId = callStore.markCurrentCallEnded() else {
            return
        }
        
        signalingService.sendEnd(toUserId: peerUserId)
        webRTCClient.close()
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
            signalingService.sendDecline(toUserId: payload.fromUserId)
            
            return
        }
        
        callStore.registerIncomingCall(
            currentUserId: currentUserId,
            fromUserId: payload.fromUserId,
            sdp: payload.sdp,
            type: payload.type
        )
    }
    
    private func handleIncomingCallAnswer(_ payload: CallAnswerPayload) {
        Task {
            do {
                callStore.markOutgoingCallAccepted(
                    fromUserId: payload.fromUserId,
                    sdp: payload.sdp
                )
                
                let answer = RTCSessionDescription(
                    type: .answer,
                    sdp: payload.sdp
                )
                
                try await webRTCClient.setRemoteDescription(answer)
            } catch {
                print("Failed to set remote answer:", error)
                callStore.reset()
                webRTCClient.close()
            }
        }
    }
    
    private func handleIncomingCallCancel(_ payload: CallCancelPayload) {
        callStore.markCallCancelledByPeer(fromUserId: payload.fromUserId)
        webRTCClient.close()
    }

    private func handleIncomingCallEnd(_ payload: CallEndPayload) {
        callStore.markCallEndedByPeer(fromUserId: payload.fromUserId)
        webRTCClient.close()
    }
    
    private func handleIncomingCallIceCandidate(_ payload: CallIceCandidatePayload) {
        Task {
            do {
                let candidate = RTCIceCandidate(
                    sdp: payload.sdp,
                    sdpMLineIndex: payload.sdpMLineIndex,
                    sdpMid: payload.sdpMid
                )
                
                try await webRTCClient.addIceCandidate(candidate)
            } catch {
                print("Failed to add ICE candidate:", error)
            }
        }
    }
    
    private func sendIceCandidate(_ candidate: RTCIceCandidate) {
        guard let call = callStore.call else { return }
        
        signalingService.sendIceCandidate(
            toUserId: call.direction == .outgoing ? call.calleeUserId : call.callerUserId,
            sdp: candidate.sdp,
            sdpMLineIndex: candidate.sdpMLineIndex,
            sdpMid: candidate.sdpMid,
        )
    }
}

class MockCallCoordinator: ObservableObject, CallCoordinatorProtocol {
    func startCall(targetUserId: String, type: CallType) {}
    
    func acceptCall() {}
    
    func declineCall() {}
    
    func cancelOutgoingCall() {}
    
    func endCurrentCall() {}
}
