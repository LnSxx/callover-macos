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

extension ContactDTO {
    func toDomain() -> Contact {
        Contact(
            id: id,
            ownerId: ownerId,
            contactUserId: contactUserId,
            alias: alias,
            note: note,
            isFavourite: isFavourite,
            isBlocked: isBlocked,
            isMuted: isMuted,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: updatedAt) ?? Date(),
        )
    }
}
