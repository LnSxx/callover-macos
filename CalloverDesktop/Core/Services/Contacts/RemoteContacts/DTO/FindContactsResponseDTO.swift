//
//  FindContactsResponseDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import Foundation

struct FindContactsResponseDTO: Codable {
    let items: [ContactDTO]
    let nextCursor: String?
}
