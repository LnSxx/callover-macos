//
//  NotificationType.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

enum NotificationType: String, Codable  {
    case missedCall = "missed_call"
    case mutedCall = "muted_call"
    case serviceMessage = "service_message"
}
