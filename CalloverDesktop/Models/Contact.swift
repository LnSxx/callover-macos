//
//  Contact.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

struct Contact: Identifiable, Equatable {
    let id: String
    let ownerId: String
    let contactUserId: String
    var alias: String?
    var note: String?
    var isFavourite: Bool
    var isBlocked: Bool
    var isMuted: Bool
    let createdAt: Date
    let updatedAt: Date
}
