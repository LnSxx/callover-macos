//
//  PushTokensService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

import Foundation

protocol PushTokensServiceProtocol {
    func savePushToken(token: String) async throws -> Void
    func deletePushToken(token: String) async throws -> Void
}

struct PushTokensService: PushTokensServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func savePushToken(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/push-tokens") else {
            throw NetworkError.invalidUrl
        }
        
        let appDeviceInfo = AppDeviceInfoProvider.current
        
        let dto = SavePushTokenRequestDTO(
            provider: "apns",
            platform: "macos",
            token: token,
            bundleId: appDeviceInfo.bundleId,
            appVersion: appDeviceInfo.appVersion
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(dto)
        
        try await networkClient.sendEmpty(request)
    }
    
    func deletePushToken(token: String) async throws {
        guard let url = URL(string: "\(baseURL)/push-tokens/current") else {
            throw NetworkError.invalidUrl
        }
        
        let dto = DeletePushTokenRequestDTO(
            provider: "apns",
            token: token,
        )
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(dto)
        
        try await networkClient.sendEmpty(request)
    }
}
