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
    
    // Contact user ID validation errors
    case CONTACT_UID_INVALID
    
    // Contact name validation errors
    case CONTACT_NAME_TOO_BIG
}

extension ERValidationErrorCode {
    var message: String {
        switch self {
        case .USERNAME_IS_REQUIRED:
            return "Username is required"
        case .USERNAME_TOO_SHORT:
            return "Username is too short. Min length is 4 symbols"
        case .USERNAME_TOO_LONG:
            return "Username is too long. Max length is 25 symbols"
        case .USERNAME_INVALID_SYMBOLS:
            return "Username should not contain invalid symbols"
        case .USERNAME_ONLY_NUMBERS:
            return "Username cannot contain only numbers"
        case .USERNAME_STARTS_WITH_NUMBER:
            return "Username cannot start with number"
        case .USERNAME_END_INVALID:
            return "Username's end is invalid"
        case .USERNAME_CONSECUTIVE_DOTS_UNDERSCORES:
            return "Username contains consecutive dots and or underscores"
            
        case .PASSWORD_IS_REQUIRED:
            return "Password is required"
        case .PASSWORD_TOO_SHORT:
            return "Password is too short. Min length is 8 symbols"
        case .PASSWORD_TOO_BIG:
            return "Password is too big. Max length is 72 bytes"
        case .PASSWORD_EDGE_WHITESPACE:
            return "Remove edge whitespaces from password"
        case .PASSWORD_HAS_CONTROLS:
            return "Remove controls from password"
            
        case .CONTACT_UID_INVALID:
            return "Contact user ID is invalid"
            
        case .CONTACT_NAME_TOO_BIG:
            return "Contact name is invalid"
        }
    }
}
