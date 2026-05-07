//
//  ContactExtension.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

extension ContactEntity {
    func toDomain() -> Contact {
        Contact(
            id: id ?? "",
            ownerId: ownerId ?? "",
            contactUserId: contactUserId ?? "",
            alias: alias,
            note: note,
            isFavourite: isFavourite,
            isBlocked: isBlocked,
            isMuted: isMuted,
            createdAt: createdAt ?? Date(),
            updatedAt: updatedAt ?? Date()
        )
    }
}
