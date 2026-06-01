//
//  GetCallLogsResponseDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

struct GetCallLogsResponseDTO: Codable {
    let data: [CallLogDTO]
    let nextCursor: String?
}
