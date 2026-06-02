//
//  NotificationServicePayloadDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

struct NotificationServicePayloadDTO: Codable {
    let code: String?
}

extension NotificationServicePayloadDTO {
    func toDomain() -> NotificationServicePayload {
        NotificationServicePayload(
            code: code
        )
    }
}
