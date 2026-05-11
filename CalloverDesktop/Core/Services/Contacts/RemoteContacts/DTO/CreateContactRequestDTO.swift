//
//  CreateContactDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 11.05.26.
//

import Foundation

struct CreateContactRequestDTO: Encodable {
    let contactUserId: String
    let alias: String
    let isFavourite: Bool?
}
