//
//  ChangePasswordRequest.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import Foundation

struct ChangePasswordRequestDTO: Encodable {
    let password: String
    let newPassword: String
}
