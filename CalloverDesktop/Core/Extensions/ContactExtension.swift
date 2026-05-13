//
//  ContactExtension.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import Foundation

extension Contact {
    var displayName: String {
        let alias = alias?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let alias, !alias.isEmpty {
            return alias
        }
        
        return "@\(contactUserId)"
    }
    
    var initials: String {
        String(displayName.prefix(1)).uppercased()
    }
}
