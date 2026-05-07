//
//  ContactDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

struct ContactDTO: Codable {
    let id: String
    let ownerId: String
    let contactUserId: String
    let alias: String?
    let note: String?
    let isFavourite: Bool
    let isBlocked: Bool
    let isMuted: Bool
    let createdAt: String
    let updatedAt: String
}
