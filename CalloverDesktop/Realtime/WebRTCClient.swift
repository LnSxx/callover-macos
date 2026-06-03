//
//  WebRTCClient.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import Foundation
import Combine
import AVFoundation
import WebRTC

@MainActor
final class WebRTCClient: NSObject, ObservableObject, RTCPeerConnectionDelegate {
    private let factory = RTCPeerConnectionFactory()
    
    private var peerConnection: RTCPeerConnection?
    private var videoCapturer: RTCCameraVideoCapturer?
    
    private var localAudioTrack: RTCAudioTrack?
    private var localVideoTrack: RTCVideoTrack?
    
    private let mediaStore: CallMediaStore
    
    private var pendingIceCandidates: [RTCIceCandidate] = []
    private var hasRemoteDescription = false
    
    var onIceCandidate: ((RTCIceCandidate) -> Void)?
    
    init(mediaStore: CallMediaStore) {
        self.mediaStore = mediaStore
        super.init()
    }
    
    func startLocalMedia(
        includeVideo: Bool = true
    ) async throws {
        let hasMicrophonePermission = await requestPermission(for: .audio)

        if hasMicrophonePermission {
            let audioSource = factory.audioSource(with: nil)
            let audioTrack = factory.audioTrack(
                with: audioSource,
                trackId: "local-audio"
            )

            localAudioTrack = audioTrack
        }

        guard includeVideo else {
            return
        }

        let hasCameraPermission = await requestPermission(for: .video)

        guard hasCameraPermission else {
            return
        }

        let videoSource = factory.videoSource()
        let videoTrack = factory.videoTrack(
            with: videoSource,
            trackId: "local-video"
        )

        localVideoTrack = videoTrack
        mediaStore.localVideoTrack = videoTrack

        let capturer = RTCCameraVideoCapturer(delegate: videoSource)
        videoCapturer = capturer

        guard let device = RTCCameraVideoCapturer.captureDevices().first,
              let format = RTCCameraVideoCapturer.supportedFormats(for: device).last else {
            return
        }

        let fps = format.videoSupportedFrameRateRanges
            .map { Int($0.maxFrameRate) }
            .max() ?? 30

        try await capturer.startCapture(
            with: device,
            format: format,
            fps: min(fps, 30)
        )
    }
    
    func createPeerConnection(
        includeVideo: Bool = true
    ) {
        let config = RTCConfiguration()
        config.iceServers = [
            RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])
        ]
        config.sdpSemantics = .unifiedPlan
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: nil,
            optionalConstraints: nil
        )
        
        let peerConnection = factory.peerConnection(
            with: config,
            constraints: constraints,
            delegate: self
        )
        
        self.peerConnection = peerConnection
        
        guard let peerConnection else {
            return
        }
        
        if let localAudioTrack {
            peerConnection.add(
                localAudioTrack,
                streamIds: ["callover-stream"]
            )
        }
        
        if includeVideo, let localVideoTrack {
            peerConnection.add(
                localVideoTrack,
                streamIds: ["callover-stream"]
            )
        }
    }
    
    func createOffer(
        includeVideo: Bool = true
    ) async throws -> RTCSessionDescription {
        guard let peerConnection else {
            throw WebRTCClientError.peerConnectionMissing
        }
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": includeVideo ? "true" : "false"
            ],
            optionalConstraints: nil
        )
        
        let offer = try await peerConnection.offer(for: constraints)
        try await peerConnection.setLocalDescription(offer)
        
        return offer
    }
    
    func createAnswer(
        includeVideo: Bool = true
    ) async throws -> RTCSessionDescription {
        guard let peerConnection else {
            throw WebRTCClientError.peerConnectionMissing
        }
        
        let constraints = RTCMediaConstraints(
            mandatoryConstraints: [
                "OfferToReceiveAudio": "true",
                "OfferToReceiveVideo": includeVideo ? "true" : "false"
            ],
            optionalConstraints: nil
        )
        
        let answer = try await peerConnection.answer(for: constraints)
        try await peerConnection.setLocalDescription(answer)
        
        return answer
    }
    
    func setRemoteDescription(_ description: RTCSessionDescription) async throws {
        guard let peerConnection else {
            throw WebRTCClientError.peerConnectionMissing
        }
        
        try await peerConnection.setRemoteDescription(description)
        
        hasRemoteDescription = true
        try await flushPendingIceCandidates()
    }
    
    func addIceCandidate(_ candidate: RTCIceCandidate) async throws {
        guard hasRemoteDescription else {
            pendingIceCandidates.append(candidate)
            return
        }
        
        guard let peerConnection else {
            throw WebRTCClientError.peerConnectionMissing
        }
        try await peerConnection.add(candidate)
    }
    
    func toggleCamera() {
        mediaStore.isCameraEnabled.toggle()
        localVideoTrack?.isEnabled = mediaStore.isCameraEnabled
    }
    
    func toggleMicrophone() {
        mediaStore.isMicrophoneEnabled.toggle()
        localAudioTrack?.isEnabled = mediaStore.isMicrophoneEnabled
    }
    
    func close() {
        videoCapturer?.stopCapture()
        peerConnection?.close()
        
        videoCapturer = nil
        peerConnection = nil
        localAudioTrack = nil
        localVideoTrack = nil
        
        pendingIceCandidates.removeAll()
        hasRemoteDescription = false
        
        mediaStore.clear()
    }
    
    private func requestPermission(for mediaType: AVMediaType) async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: mediaType)
        default:
            return false
        }
    }
    
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didGenerate candidate: RTCIceCandidate
    ) {
        Task { @MainActor in
            self.onIceCandidate?(candidate)
        }
    }
    
    func peerConnection(
        _ peerConnection: RTCPeerConnection,
        didAdd rtpReceiver: RTCRtpReceiver,
        streams: [RTCMediaStream]
    ) {
        guard let videoTrack = rtpReceiver.track as? RTCVideoTrack else {
            return
        }
        
        Task { @MainActor in
            self.mediaStore.remoteVideoTrack = videoTrack
        }
    }
    
    private func flushPendingIceCandidates() async throws {
        guard let peerConnection else {
            throw WebRTCClientError.peerConnectionMissing
        }
        
        let candidates = pendingIceCandidates
        pendingIceCandidates.removeAll()
        
        for candidate in candidates {
            try await peerConnection.add(candidate)
        }
    }
}

enum WebRTCClientError: Error {
    case peerConnectionMissing
}
