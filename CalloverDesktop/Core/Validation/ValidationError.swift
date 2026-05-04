//
//  ValidationError.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation

enum ValidationError: Error, LocalizedError {
    case fieldEmpty
    case tooShort(min: Int)
    case tooLong(max: Int)
    case invalidFormat
    case custom(String)

    var errorDescription: String? {
        switch self {
        case .fieldEmpty:
            return "Field is can not be empty"
        case .tooShort(let min):
            return "Minimum length — \(min) symbols"
        case .tooLong(let max):
            return "Maximum length - \(max) symbols"
        case .invalidFormat:
            return "Invalid format"
        case .custom(let message):
            return message
        }
    }
}
