//
//  LocalWebRTCMediaStore.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import Foundation
import Combine
import AVFoundation
import WebRTC

@MainActor
final class LocalWebRTCMediaStore: ObservableObject {
    @Published var localVideoTrack: RTCVideoTrack?
    @Published var localAudioTrack: RTCAudioTrack?

    @Published var isCameraEnabled = true
    @Published var isMicrophoneEnabled = true

    @Published var hasCameraPermission = false
    @Published var hasMicrophonePermission = false

    @Published var hasCameraDevice = false
    @Published var errorMessage: String?
    
    private let factory = RTCPeerConnectionFactory()
    private var videoCapturer: RTCCameraVideoCapturer?

    var videoPlaceholderTitle: String? {
        if !hasCameraPermission {
            return "Camera permission is not granted"
        }

        if !hasCameraDevice {
            return "No camera available"
        }

        if !isCameraEnabled {
            return "Camera is off"
        }

        if localVideoTrack == nil {
            return "Starting camera..."
        }

        return nil
    }

    func setup() async {
        await requestPermissions()
        createLocalAudioTrack()
        createLocalVideoTrack()
    }

    private func requestPermissions() async {
        hasCameraPermission = await requestPermission(for: .video)
        hasMicrophonePermission = await requestPermission(for: .audio)
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

    private func createLocalAudioTrack() {
        guard hasMicrophonePermission else {
            localAudioTrack = nil
            return
        }

        let audioSource = factory.audioSource(with: nil)
        let audioTrack = factory.audioTrack(
            with: audioSource,
            trackId: "local-audio-track"
        )

        audioTrack.isEnabled = isMicrophoneEnabled
        localAudioTrack = audioTrack
    }

    private func createLocalVideoTrack() {
        guard hasCameraPermission else {
            localVideoTrack = nil
            return
        }

        guard let device = RTCCameraVideoCapturer.captureDevices().first else {
            hasCameraDevice = false
            localVideoTrack = nil
            return
        }

        hasCameraDevice = true

        let videoSource = factory.videoSource()
        let videoTrack = factory.videoTrack(
            with: videoSource,
            trackId: "local-video-track"
        )

        videoTrack.isEnabled = isCameraEnabled
        localVideoTrack = videoTrack

        let capturer = RTCCameraVideoCapturer(delegate: videoSource)
        videoCapturer = capturer

        guard let format = RTCCameraVideoCapturer.supportedFormats(for: device).last else {
            errorMessage = "No supported camera format"
            return
        }

        let fps = format.videoSupportedFrameRateRanges
            .map { Int($0.maxFrameRate) }
            .max() ?? 30

        capturer.startCapture(
            with: device,
            format: format,
            fps: min(fps, 30)
        )
    }

    func toggleCamera() {
        isCameraEnabled.toggle()
        localVideoTrack?.isEnabled = isCameraEnabled
    }

    func toggleMicrophone() {
        isMicrophoneEnabled.toggle()
        localAudioTrack?.isEnabled = isMicrophoneEnabled
    }

    func stop() {
        videoCapturer?.stopCapture()
        videoCapturer = nil

        localVideoTrack = nil
        localAudioTrack = nil
    }
}
