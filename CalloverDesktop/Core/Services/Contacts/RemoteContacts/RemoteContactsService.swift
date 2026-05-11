//
//  RemoteContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

protocol RemoteContactsServiceProtocol {
    func createContact(
        contactUserId: String,
        name: String,
        isAddingToFavourites: Bool,
    ) async throws -> ContactDTO
    
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
    
    func createContact(
        contactUserId: String,
        name: String,
        isAddingToFavourites: Bool,
    ) async throws -> ContactDTO {
        guard let url = URL(string: "\(baseURL)/contacts") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            CreateContactRequestDTO(
                contactUserId: contactUserId,
                alias: name,
                isFavourite: isAddingToFavourites
            )
        )
        
        return try await networkClient.send(request)
    }
    
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
