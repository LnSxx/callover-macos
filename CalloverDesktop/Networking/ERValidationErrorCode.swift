//
//  ERValidationErrorCode.swift
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

enum ERValidationErrorCode: String, Codable {
    // Username validation errors
    // Used for register & update user profile
    case USERNAME_IS_REQUIRED
    case USERNAME_TOO_SHORT
    case USERNAME_TOO_LONG
    case USERNAME_INVALID_SYMBOLS
    case USERNAME_ONLY_NUMBERS
    case USERNAME_STARTS_WITH_NUMBER
    case USERNAME_END_INVALID
    case USERNAME_CONSECUTIVE_DOTS_UNDERSCORES
    
    // Password validation errors
    // Used for register & update user profile
    case PASSWORD_IS_REQUIRED
    case PASSWORD_TOO_SHORT
    case PASSWORD_TOO_BIG
    case PASSWORD_EDGE_WHITESPACE
    case PASSWORD_HAS_CONTROLS
}
