//
//  GetNotificationsResponseDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

struct GetNotificationsResponseDTO: Codable {
    let data: [NotificationDTO]
    let totalUnreadCount: Int
    let pagination: GetNotificationsResponsePaginationDTO
}
