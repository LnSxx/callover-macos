//
//  Notification.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import Foundation

struct Notification: Identifiable, Equatable, Hashable {
    let id: String
    let userId: String
    let type: NotificationType
    let status: NotificationStatus
    let title: String
    let body: String?
    let call: NotificationCall?
    let service: NotificationServicePayload?
    let readAt: Date?
    let expiresAt: Date
    let createdAt: Date
}
