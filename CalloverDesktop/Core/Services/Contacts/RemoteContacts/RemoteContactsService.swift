//
//  RemoteContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

protocol RemoteContactsServiceProtocol {
    func fetchContacts(
        changedAfter: Date?,
        cursor: String?,
        limit: Int
    ) async throws -> FindContactsResponseDTO
}

class RemoteContactsService: RemoteContactsServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    func fetchContacts(
        changedAfter: Date?,
        cursor: String?,
        limit: Int
    ) async throws -> FindContactsResponseDTO {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("contacts"),
            resolvingAgainstBaseURL: false
        )
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        if let changedAfter {
            queryItems.append(
                URLQueryItem(
                    name: "changedAfter",
                    value: isoFormatter.string(from: changedAfter)
                )
            )
        }
        
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
