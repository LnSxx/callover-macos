//
//  SavePushTokenRequestDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

struct SavePushTokenRequestDTO: Encodable {
    let provider: String
    let platform: String
    let token: String
    let bundleId: String
    let appVersion: String
}
