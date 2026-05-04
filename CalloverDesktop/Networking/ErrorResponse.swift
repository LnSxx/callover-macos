//
//  ErrorResponse.swift
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

struct ErrorResponse: Equatable, Codable {
    let statusCode: Int
    let code: String
    let message: String
    let path: String
    let timestamp: String
    let errors: [ERValidationError]?
}
