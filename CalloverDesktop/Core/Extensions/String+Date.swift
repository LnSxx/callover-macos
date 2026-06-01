//
//  StringExtension.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

extension String {
    func toISODate() throws -> Date {
        guard let date = ISO8601DateFormatter.api.date(from: self) else {
            throw MappingError.invalidDate(self)
        }
        return date
    }
}

extension ISO8601DateFormatter {
    static let api: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        return formatter
    }()
}
