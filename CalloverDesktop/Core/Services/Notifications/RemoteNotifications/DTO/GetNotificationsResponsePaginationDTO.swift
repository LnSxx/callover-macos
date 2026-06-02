//
//  GetNotificationsResponsePaginationDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

struct GetNotificationsResponsePaginationDTO: Codable {
    let limit: Int
    let offset: Int
    let count: Int
    let total: Int
    let next: String?
    let previous: String?
}
