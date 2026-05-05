//
//  ProfileService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 05.05.26.
//

import Foundation

protocol ProfileServiceProtocol {
    func getProfile() async throws -> UserProfile
}

struct ProfileService: ProfileServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func getProfile() async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/profile/me") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await networkClient.send(request)
    }
}
