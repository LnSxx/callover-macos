//
//  UserProfile.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import Foundation

struct UserProfile: Equatable, Codable {
    let id: String
    let email: String?
    let createdAt: Date
}
