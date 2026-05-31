//
//  CallStore.swift
//  CalloverDesktop
//
//  Created by Leonid  on 14.05.26.
//

import Combine

@MainActor
final class CallStore: ObservableObject {
    @Published private(set) var call: Call?
    
    var isBusy: Bool {
        guard let call else {
            return false
        }
        
        return call.status != .ended
    }
    
    @discardableResult
    func registerOutgoingCall(
        currentUserId: String,
        targetUserId: String,
        type: CallType
    ) -> Bool {
        guard call == nil else {
            return false
        }

        call = Call(
            callerUserId: currentUserId,
            calleeUserId: targetUserId,
            direction: .outgoing,
            status: .calling,
            type: type,
            remoteDescription: nil
        )

        return true
    }
    
    func registerIncomingCall(
        currentUserId: String,
        fromUserId: String,
        sdp: String,
        type: CallType,
    ) {
        guard call == nil else {
            return
        }
        
        call = Call(
            callerUserId: fromUserId,
            calleeUserId: currentUserId,
            direction: .incoming,
            status: .ringing,
            type: type,
            remoteDescription: SessionDescription(
                type: .offer,
                sdp: sdp
            )
        )
    }
    
    func markIncomingCallAccepted() {
        guard var currentCall = call else {
            return
        }
        guard currentCall.direction == .incoming else {
            return
        }
        guard currentCall.status == .ringing else {
            return
        }
        currentCall.status = .connecting
        call = currentCall
    }
    
    func markOutgoingCallAccepted(
        fromUserId: String,
        sdp: String,
    ) {
        guard var currentCall = call else {
            return
        }
        
        guard currentCall.direction == .outgoing else {
            return
        }
        
        guard currentCall.status == .calling else {
            return
        }
        
        guard currentCall.calleeUserId == fromUserId else {
            return
        }
        
        currentCall.status = .connecting
        currentCall.remoteDescription = SessionDescription(
            type: .answer,
            sdp: sdp
        )
        
        call = currentCall
    }
    
    func clearDeclinedOutgoingCall(fromUserId: String) {
        guard let currentCall = call else {
            return
        }
        
        guard currentCall.direction == .outgoing else {
            return
        }
        
        guard currentCall.status == .calling else {
            return
        }
        
        guard currentCall.calleeUserId == fromUserId else {
            return
        }
        
        call = nil
    }
    
    func markCallCancelledByPeer(fromUserId: String) {
        guard let currentCall = call else {
            return
        }
        
        guard currentCall.direction == .incoming else {
            return
        }
        
        guard currentCall.status == .ringing else {
            return
        }
        
        guard currentCall.callerUserId == fromUserId else {
            return
        }
        
        call = nil
    }
    
    func markCallDeclinedByPeer(fromUserId: String) {
        guard let currentCall = call else {
            return
        }
        
        guard currentCall.direction == .outgoing else {
            return
        }
        
        guard currentCall.status == .calling else {
            return
        }
        
        guard currentCall.calleeUserId == fromUserId else {
            return
        }
        
        call = nil
    }
    
    func markCallEndedByPeer(fromUserId: String) {
        guard let currentCall = call else {
            return
        }

        let expectedPeerId = currentCall.direction == .incoming
            ? currentCall.callerUserId
            : currentCall.calleeUserId

        guard expectedPeerId == fromUserId else {
            return
        }

        reset()
    }
    
    func declineIncomingCall() -> String? {
        guard let currentCall = call else {
            return nil
        }
        guard currentCall.direction == .incoming else {
            return nil
        }
        guard currentCall.status == .ringing else {
            return nil
        }
        let targetUserId = currentCall.callerUserId
        reset()
        return targetUserId
    }
    
    func cancelOutgoingCall() -> String? {
        guard let currentCall = call else {
            return nil
        }
        guard currentCall.direction == .outgoing else {
            return nil
        }
        guard currentCall.status == .calling else {
            return nil
        }
        let targetUserId = currentCall.calleeUserId
        reset()
        return targetUserId
    }
    
    func markCurrentCallEnded() -> String? {
        guard let currentCall = call else {
            return nil
        }

        guard currentCall.status == .active || currentCall.status == .connecting || currentCall.status == .calling else {
            return nil
        }

        let peerId = currentCall.direction == .incoming
            ? currentCall.callerUserId
            : currentCall.calleeUserId

        reset()

        return peerId
    }
    
    func markCurrentCallEndedByTimeout() {
        reset()
    }
    
    func reset() {
        call = nil
    }
}
