//
//  RemoteCallLogsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

protocol RemoteCallLogsServiceProtocol {
    func fetchCallLogs(
        limit: Int,
        cursor: String?
    ) async throws -> GetCallLogsResponseDTO
}

class RemoteCallLogsService: RemoteCallLogsServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func fetchCallLogs(
        limit: Int,
        cursor: String?
    ) async throws -> GetCallLogsResponseDTO {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("call-logs"),
            resolvingAgainstBaseURL: false
        )
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let cursor {
            queryItems.append(
                URLQueryItem(name: "cursor", value: cursor)
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
}
