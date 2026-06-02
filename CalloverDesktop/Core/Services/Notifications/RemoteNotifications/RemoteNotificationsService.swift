//
//  RemoteNotificationsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import Foundation

protocol RemoteNotificationsServiceProtocol {
    func fetchNotifications(
        limit: Int,
        offset: Int,
        status: NotificationStatus?
    ) async throws -> GetNotificationsResponseDTO
    
    func fetchNextNotifications(
        next: String,
    ) async throws -> GetNotificationsResponseDTO
}

class RemoteNotificationsService: RemoteNotificationsServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func fetchNotifications(
        limit: Int,
        offset: Int,
        status: NotificationStatus?
    ) async throws -> GetNotificationsResponseDTO {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("notifications"),
            resolvingAgainstBaseURL: false
        )
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        
        if let status {
            queryItems.append(
                URLQueryItem(name: "status", value: status.rawValue)
            )
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NetworkError.unexpectedResponse(nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await networkClient.send(request)
    }
    
    func fetchNextNotifications(
        next: String,
    ) async throws -> GetNotificationsResponseDTO {
        let components = URLComponents(
            url: baseURL.appendingPathComponent(next),
            resolvingAgainstBaseURL: false
        )
        
        guard let url = components?.url else {
            throw NetworkError.unexpectedResponse(nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await networkClient.send(request)
    }
}
