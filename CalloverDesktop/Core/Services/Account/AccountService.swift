//
//  AccountService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import Foundation

protocol AccountServiceProtocol {
    func changePassword(currentPassword: String, newPassword: String) async throws -> UserProfile
    func deleteAccount() async throws -> Void
}

struct AccountService: AccountServiceProtocol {
    private let baseURL = AppConfig.apiBaseURL
    private let networkClient = NetworkClient()
    
    func changePassword(currentPassword: String, newPassword: String) async throws -> UserProfile {
        guard let url = URL(string: "\(baseURL)/account/password") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONEncoder().encode(
            ChangePasswordRequestDTO(password: currentPassword, newPassword: newPassword)
        )
        
        return try await networkClient.send(request)
    }
    
    func deleteAccount() async throws -> Void {
        guard let url = URL(string: "\(baseURL)/account") else {
            throw NetworkError.invalidUrl
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        try await networkClient.sendEmpty(request)
    }
}
