//
//  CallTimeoutReason.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

enum CallTimeoutReason: String, Codable {
    case noAnswer = "no_answer"
    case maxDuration = "max_duration"
}
