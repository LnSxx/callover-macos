//
//  RemoteContactsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

protocol RemoteContactsServiceProtocol {
    func createContact(dto: CreateContactRequestDTO) async throws -> ContactDTO
    
    func fetchContacts(
        changedAfter: Date?,
        cursor: String?,
        limit: Int
    ) async throws -> FindContactsResponseDTO
    
    func updateContact(
        id: String,
        dto: UpdateContactRequestDTO,
    ) async throws -> ContactDTO
    
    func deleteContact(id: String) async throws -> Void
}

class RemoteContactsService: RemoteContactsServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    private let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    func createContact(dto: CreateContactRequestDTO) async throws -> ContactDTO {
        guard let url = URL(string: "\(baseURL)/contacts") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(dto)
        
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
    
    func updateContact(
        id: String,
        dto: UpdateContactRequestDTO,
    ) async throws -> ContactDTO {
        guard let url = URL(string: "\(baseURL)/contacts/\(id)") else {
            throw NetworkError.invalidUrl
        }
        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(dto)
        
        return try await networkClient.send(request)
    }
    
    func deleteContact(id: String) async throws {
        guard let url = URL(string: "\(baseURL)/contacts/\(id)") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        try await networkClient.sendEmpty(request)
    }
}
