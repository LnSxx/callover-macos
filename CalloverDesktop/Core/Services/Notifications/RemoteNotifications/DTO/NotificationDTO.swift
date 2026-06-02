//
//  NotificationDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import Foundation

struct NotificationDTO: Codable {
    let id: String
    let userId: String
    let type: NotificationType
    let status: NotificationStatus
    let title: String
    let body: String?
    let call: NotificationCallDTO?
    let service: NotificationServicePayloadDTO?
    let readAt: String?
    let expiresAt: String
    let createdAt: String
}

extension NotificationDTO {
    func toDomain() throws -> Notification {
        Notification(
            id: id,
            userId: userId,
            type: type,
            status: status,
            title: title,
            body: body,
            call: call?.toDomain(),
            service: service?.toDomain(),
            readAt: try readAt?.toISODate(),
            expiresAt: try expiresAt.toISODate(),
            createdAt: try createdAt.toISODate(),
        )
    }
}
