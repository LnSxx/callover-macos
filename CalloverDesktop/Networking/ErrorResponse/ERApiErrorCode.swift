//
//  ERAPIErrorCode.swift
//  CalloverDesktop
//
//  Created by Leonid  on 05.05.26.
//

enum ERApiErrorCode: String, Codable {
    case VALIDATION_ERROR
    case INVALID_CREDENTIALS
    case AUTHENTICATION_REQUIRED
    case SESSION_EXPIRED
    case INTERNAL_SERVER_ERROR
    case CONFLICT
    case PAYLOAD_TOO_LARGE
    case TOO_MANY_REQUESTS
}
