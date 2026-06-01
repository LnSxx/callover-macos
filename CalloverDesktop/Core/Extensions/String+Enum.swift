//
//  String+Enum.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

extension String {
    func toEnum<T: RawRepresentable>(
        _ type: T.Type,
        field: String
    ) throws -> T where T.RawValue == String {
        guard let value = T(rawValue: self) else {
            throw CallLogMappingError.invalidEnum(field: field, value: self)
        }

        return value
    }
}
