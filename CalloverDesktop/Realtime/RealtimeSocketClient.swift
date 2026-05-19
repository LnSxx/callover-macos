//
//  RealtimeSocketClient.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation
import SocketIO

protocol RealtimeSocketClientProtocol: AnyObject {
    var onEvent: ((RealtimeEvent) -> Void)? { get set }
    
    func connect()
    func disconnect()
    func emit(_ event: String, payload: [String: Any])
}

final class RealtimeSocketClient: RealtimeSocketClientProtocol {
    var onEvent: ((RealtimeEvent) -> Void)?
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let decoder = JSONDecoder()
    
    init(baseURL: URL) {
        self.manager = SocketManager(
            socketURL: baseURL,
            config: [
                .log(false),
                .compress,
                .forceWebsockets(true),
                .path("/socket.io")
            ]
        )
        
        self.socket = manager.socket(forNamespace: "/events")
        
        setupHandlers()
    }
    
    func connect() {
        guard socket.status != .connected && socket.status != .connecting else {
            return
        }
        
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func emit(_ event: String, payload: [String: Any]) {
        socket.emit(event, payload)
    }
    
    private func setupHandlers() {
        socket.on(clientEvent: .connect) { _, _ in
            print("Realtime socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { data, _ in
            print("Realtime socket disconnected:", data)
        }
        
        socket.on(clientEvent: .error) { data, _ in
            print("Realtime socket error:", data)
        }
        
        socket.on("message") { [weak self] data, _ in
            self?.handleMessage(data)
        }
    }
    
    private func handleMessage(_ data: [Any]) {
        guard let rawMessage = data.first else {
            return
        }
        
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: rawMessage,
                options: []
            )
            
            let event = try decoder.decode(RealtimeEvent.self, from: jsonData)
            
            DispatchQueue.main.async { [weak self] in
                self?.onEvent?(event)
            }
        } catch {
            print("Failed to decode realtime event:", error)
        }
    }
}

final class MockRealtimeSocketClient: RealtimeSocketClientProtocol {
    var onEvent: ((RealtimeEvent) -> Void)?
    
    func connect() {}
    func disconnect() {}
    func emit(_ event: String, payload: [String : Any]) {}
}
