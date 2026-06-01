//
//  CallLogStatus.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

enum CallLogStatus: String, Codable  {
    case completed
    case missed
    case declined
    case cancelled
    case noAnswer = "no_answer"
    case failed
}
