//
//  CurrentCallService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

import Foundation

protocol CurrentCallServiceProtocol {
    func getCurrentRingingCall() async throws -> GetCurrentCallResponseDTO
}

struct CurrentCallService: CurrentCallServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func getCurrentRingingCall() async throws -> GetCurrentCallResponseDTO {
        let components = URLComponents(
            url: baseURL.appendingPathComponent("calls/current"),
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

struct MockCurrentCallService: CurrentCallServiceProtocol {
    func getCurrentRingingCall() async throws -> GetCurrentCallResponseDTO {
        return GetCurrentCallResponseDTO(call: nil, pendingIceCandidates: [])
    }
}
