//
//  Validator.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation

enum Validator {
    static func validateUsername(_ username: String) -> Result<Void, ValidationError> {
        // Trim on start and the end of given string
        let trimmed = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1. Should not be empty
        if username.isEmpty {
            return .failure(.fieldEmpty)
        }
        
        // 2. Should not contain spaces on start and on end
        if username != trimmed {
            return .failure(.custom("Username must not contain leading or trailing spaces"))
        }
        
        // 3. Check length constraints
        if username.count < 4 {
            return .failure(.tooShort(min: 4))
        }
        
        if username.count > 25 {
            return .failure(.tooLong(max: 25))
        }
        
        // 4. Should be only in latin letters
        let allowedCharset = CharacterSet.alphanumerics
        if username.rangeOfCharacter(from: allowedCharset.inverted) != nil {
            return .failure(.custom("Only latin letters and numbers are allowed"))
        }
        
        // 5. Only ASCII
        if !username.canBeConverted(to: .ascii) {
            return .failure(.custom("Only English characters are allowed"))
        }
        
        // 6. Should not start with a number
        if let first = username.first, first.isNumber {
            return .failure(.custom("Username must not start with a number"))
        }
        
        // 7. Only number - username is not allowed
        if CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: username)) {
            return .failure(.custom("Username must contain at least one letter"))
        }
        
        return .success(())
    }
    
    static func validatePassword(_ password: String) -> Result<Void, ValidationError> {
        // 1. Should not be empty
        if password.isEmpty {
            return .failure(.fieldEmpty)
        }
        
        // 2. Check length constraints
        if password.count < 8 {
            return .failure(.tooShort(min: 8))
        }
        
        if password.count > 64 {
            return .failure(.tooLong(max: 64))
        }
        
        // 3. Should not contain spaces on start and on end
        let trimmed = password.trimmingCharacters(in: .whitespacesAndNewlines)
        if password != trimmed {
            return .failure(.custom("Password must not contain leading or trailing spaces"))
        }
        
        // 4. Base complexity checks
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasDigit = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        if !(hasLowercase && hasUppercase && hasDigit) {
            return .failure(.custom("Password must contain uppercase, lowercase letters and a number"))
        }
        
        return .success(())
    }
}
