//
//  UpdateContactRequestDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.05.26.
//

import Foundation

struct UpdateContactRequestDTO: Encodable {
    let alias: String?
    let note: String?
    let isFavourite: Bool?
    let isBlocked: Bool?
    let isMuted: Bool?
}
