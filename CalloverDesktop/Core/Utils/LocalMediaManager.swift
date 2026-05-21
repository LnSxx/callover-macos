//
//  CameraManager.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import AVFoundation
import Combine

class LocalMediaManager: ObservableObject {
    @Published var session = AVCaptureSession()
    
    @Published var isCameraEnabled = true
    @Published var isMicrophoneEnabled = true
    
    @Published var hasCameraPermission = false
    @Published var hasMicrophonePermission = false
    
    @Published var hasCameraDevice = false
    @Published var hasMicrophoneDevice = false
    
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    
    var title: String {
        if !hasCameraPermission {
            return "Camera permission is not granted"
        }
        
        if !hasCameraDevice {
            return "No camera available"
        }
        
        if !isCameraEnabled {
            return "Camera is off"
        }
        
        return ""
    }
    
    func setup() async {
        await requestPermissions()
        configureSession()
    }
    
    func requestPermissions() async {
        hasCameraPermission = await AVCaptureDevice.requestAccess(for: .video)
        hasMicrophonePermission = await AVCaptureDevice.requestAccess(for: .audio)
    }
    
    func configureSession() {
        session.beginConfiguration()
        
        session.inputs.forEach { session.removeInput($0) }
        
        if let camera = AVCaptureDevice.default(for: .video) {
            hasCameraDevice = true
            
            if hasCameraPermission,
               let input = try? AVCaptureDeviceInput(device: camera),
               session.canAddInput(input) {
                session.addInput(input)
                videoInput = input
            }
        } else {
            hasCameraDevice = false
        }
        
        if let microphone = AVCaptureDevice.default(for: .audio) {
            hasMicrophoneDevice = true
            
            if hasMicrophonePermission,
               let input = try? AVCaptureDeviceInput(device: microphone),
               session.canAddInput(input) {
                session.addInput(input)
                audioInput = input
            }
        } else {
            hasMicrophoneDevice = false
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func toggleCamera() {
        isCameraEnabled.toggle()
        videoInput?.ports.forEach { $0.isEnabled = isCameraEnabled }
    }
    
    func toggleMicrophone() {
        isMicrophoneEnabled.toggle()
        audioInput?.ports.forEach { $0.isEnabled = isMicrophoneEnabled }
    }
}
