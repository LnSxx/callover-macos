//
//  CallLogMappingError.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

enum CallLogMappingError: Error {
    case missingRequiredField(String)
    case invalidEnum(field: String, value: String)
}
