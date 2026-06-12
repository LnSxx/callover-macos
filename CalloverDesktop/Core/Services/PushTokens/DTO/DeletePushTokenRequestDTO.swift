//
//  DeletePushTokenRequestDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

struct DeletePushTokenRequestDTO: Encodable {
    let provider: String
    let token: String
}
