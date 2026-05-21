//
//  CallMediaStore.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import Foundation
import Combine
import WebRTC

@MainActor
final class CallMediaStore: ObservableObject {
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var remoteVideoTrack: RTCVideoTrack?

    @Published var isCameraEnabled = true
    @Published var isMicrophoneEnabled = true

    func clear() {
        localVideoTrack = nil
        remoteVideoTrack = nil
        isCameraEnabled = true
        isMicrophoneEnabled = true
    }
}
