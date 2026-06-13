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
    func restoreCurrentRingingCallIfNeeded() async 
}

@MainActor
final class CallCoordinator: ObservableObject, CallCoordinatorProtocol, RealtimeEventHandler {
    private let currentUserId: String
    private let signalingService: SignalingServiceProtocol
    private let callStore: CallStore
    private let webRTCClient: WebRTCClient
    private let currentCallService: CurrentCallServiceProtocol
    
    init(
        currentUserId: String,
        signalingService: SignalingServiceProtocol,
        callStore: CallStore,
        webRTCClient: WebRTCClient,
        currentCallService: CurrentCallServiceProtocol,
    ) {
        self.currentUserId = currentUserId
        self.signalingService = signalingService
        self.callStore = callStore
        self.webRTCClient = webRTCClient
        self.currentCallService = currentCallService
        
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
                let includeVideo = type == .video
                
                try await webRTCClient.startLocalMedia(
                    includeVideo: includeVideo
                )
                webRTCClient.createPeerConnection(
                    includeVideo: includeVideo
                )
                
                guard callStore.registerOutgoingCall(
                    currentUserId: currentUserId,
                    targetUserId: targetUserId,
                    type: type
                ) else {
                    webRTCClient.close()
                    return
                }
                
                SoundEffectPlayer.shared.playLoop(name: "calling")
                
                let offer = try await webRTCClient.createOffer(
                    includeVideo: includeVideo
                )
                
                signalingService.sendOffer(
                    toUserId: targetUserId,
                    sdp: offer.sdp,
                    type: type,
                )
            } catch {
                SoundEffectPlayer.shared.stop()
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
                
                SoundEffectPlayer.shared.playOnce(name: "call_active")
                
                let includeVideo = call.type == .video
                
                try await webRTCClient.startLocalMedia(
                    includeVideo: includeVideo
                )
                webRTCClient.createPeerConnection(
                    includeVideo: includeVideo
                )
                
                guard let sdp = call.remoteDescription?.sdp else {
                    SoundEffectPlayer.shared.stop()
                    callStore.reset()
                    webRTCClient.close()
                    return
                }
                
                let remoteOffer = RTCSessionDescription(
                    type: .offer,
                    sdp: sdp
                )
                
                try await webRTCClient.setRemoteDescription(remoteOffer)
                
                let answer = try await webRTCClient.createAnswer(
                    includeVideo: includeVideo
                )
                
                signalingService.sendAnswer(
                    toUserId: call.callerUserId,
                    sdp: answer.sdp
                )
            } catch {
                SoundEffectPlayer.shared.stop()
                callStore.reset()
                webRTCClient.close()
            }
        }
    }
    
    func declineCall() {
        guard let targetUserId = callStore.declineIncomingCall() else {
            return
        }
        
        SoundEffectPlayer.shared.playOnce(name: "call_cancelled")
        
        signalingService.sendDecline(toUserId: targetUserId)
        webRTCClient.close()
    }
    
    func cancelOutgoingCall() {
        guard let targetUserId = callStore.cancelOutgoingCall() else {
            return
        }
        
        SoundEffectPlayer.shared.playOnce(name: "call_cancelled")
        
        signalingService.sendCancel(toUserId: targetUserId)
        webRTCClient.close()
    }
    
    func endCurrentCall() {
        guard let peerUserId = callStore.markCurrentCallEnded() else {
            return
        }
        
        SoundEffectPlayer.shared.playOnce(name: "call_ended")
        
        signalingService.sendEnd(toUserId: peerUserId)
        webRTCClient.close()
    }
    
    func restoreCurrentRingingCallIfNeeded() async {
        do {
            if callStore.isBusy {
                return
            }
            
            let response = try await currentCallService.getCurrentRingingCall()
            
            guard let callDTO = response.call else {
                return
            }
            
            let call = callDTO.toDomain()
            
            guard call.status == .ringing else {
                return
            }
            
            guard let sdp = call.remoteDescription?.sdp else {
                return
            }
            
            callStore.registerIncomingCall(
                currentUserId: currentUserId,
                fromUserId: call.callerUserId,
                sdp: sdp,
                type: call.type,
            )
            
            for iceCandidate in response.pendingIceCandidates {
                try await webRTCClient.addIceCandidate(
                    iceCandidate.toRTCIceCandidate()
                )
            }
            
            SoundEffectPlayer.shared.playLoop(name: "ringing")
        } catch {
            print("Failed to restore current ringing call:", error)
        }
    }
    
    func handle(_ event: RealtimeEvent) {
        switch event {
        case .callOffer(let payload):
            handleIncomingCallOffer(payload)
        case .callAnswer(let payload):
            handleIncomingCallAnswer(payload)
        case .callCancel(let payload):
            handleIncomingCallCancel(payload)
        case .callDecline(let payload):
            handleIncomingCallDecline(payload)
        case .callEnd(let payload):
            handleIncomingCallEnd(payload)
        case .callTimeout(let payload):
            handleIncomingCallTimeout(payload)
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
        
        if callStore.call?.status == .ringing {
            SoundEffectPlayer.shared.playLoop(name: "ringing")
        }
    }
    
    private func handleIncomingCallAnswer(_ payload: CallAnswerPayload) {
        Task {
            do {
                callStore.markOutgoingCallAccepted(
                    fromUserId: payload.fromUserId,
                    sdp: payload.sdp
                )
                
                SoundEffectPlayer.shared.playOnce(name: "call_active")
                
                let answer = RTCSessionDescription(
                    type: .answer,
                    sdp: payload.sdp
                )
                
                try await webRTCClient.setRemoteDescription(answer)
            } catch {
                print("Failed to set remote answer:", error)
                SoundEffectPlayer.shared.stop()
                callStore.reset()
                webRTCClient.close()
            }
        }
    }
    
    private func handleIncomingCallCancel(_ payload: CallCancelPayload) {
        callStore.markCallCancelledByPeer(fromUserId: payload.fromUserId)
        
        SoundEffectPlayer.shared.playOnce(name: "call_cancelled")
        webRTCClient.close()
    }
    
    private func handleIncomingCallDecline(_ payload: CallDeclinePayload) {
        callStore.markCallDeclinedByPeer(fromUserId: payload.fromUserId)
        
        SoundEffectPlayer.shared.playOnce(name: "call_cancelled")
        webRTCClient.close()
    }
    
    private func handleIncomingCallEnd(_ payload: CallEndPayload) {
        callStore.markCallEndedByPeer(fromUserId: payload.fromUserId)
        
        SoundEffectPlayer.shared.playOnce(name: "call_ended")
        webRTCClient.close()
    }
    
    private func handleIncomingCallTimeout(_ payload: CallTimeoutPayload) {
        callStore.markCurrentCallEndedByTimeout()
        
        SoundEffectPlayer.shared.playOnce(name: "call_ended")
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
    
    func restoreCurrentRingingCallIfNeeded() {}
}
