//
//  AuthService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation

protocol AuthServiceProtocol {
    func getProfile() async throws -> UserProfile
    func signIn(username: String, password: String) async throws -> UserProfile
    func signUp(username: String, password: String) async throws -> UserProfile
    func logout() async throws -> Void
}

struct AuthService: AuthServiceProtocol {
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
    
    func signIn(username: String, password: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            SignInRequest(username: username, password: password)
        )
        
        let dto: SignUpResponseDTO = try await networkClient.send(request)
        
        return dto.user
    }
    
    func signUp(username: String, password: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            SignUpRequest(username: username, password: password)
        )
        
        let dto: SignUpResponseDTO = try await networkClient.send(request)
        
        return dto.user
    }
    
    func logout() async throws -> Void {
        guard let url = URL(string: "\(baseURL)/auth/logout") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        try await networkClient.sendEmpty(request)
    }
}
