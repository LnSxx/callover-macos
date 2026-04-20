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

struct AuthSerive: AuthServiceProtocol {
    
}
