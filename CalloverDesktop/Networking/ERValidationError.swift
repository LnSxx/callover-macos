//
//  ERValidationError.swift
//  Error Response validation error struct
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

struct ERValidationError: Equatable, Codable {
    let field: String
    let code: ERValidationErrorCode
    let message: String
}
