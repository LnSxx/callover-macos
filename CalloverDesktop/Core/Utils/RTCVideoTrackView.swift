//
//  RTCVideoTrackView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import SwiftUI
import WebRTC

struct RTCVideoTrackView: NSViewRepresentable {
    let track: RTCVideoTrack

    func makeNSView(context: Context) -> RTCMTLNSVideoView {
        let view = RTCMTLNSVideoView()
        
        track.add(view)
        context.coordinator.track = track
        context.coordinator.renderer = view
        return view
    }

    func updateNSView(_ nsView: RTCMTLNSVideoView, context: Context) {
        if context.coordinator.track !== track {
            context.coordinator.track?.remove(nsView)
            track.add(nsView)
            context.coordinator.track = track
        }
    }

    static func dismantleNSView(_ nsView: RTCMTLNSVideoView, coordinator: Coordinator) {
        coordinator.track?.remove(nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        var track: RTCVideoTrack?
        var renderer: RTCVideoRenderer?
    }
}
