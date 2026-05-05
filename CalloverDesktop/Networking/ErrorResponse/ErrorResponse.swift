//
//  ErrorResponse.swift
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

struct ErrorResponse: Equatable, Codable {
    let statusCode: Int
    let code: ERApiErrorCode
    let message: String
    let path: String
    let timestamp: String
    let errors: [ERValidationError]?
}
