//
//  GetCurrentCallResponseDTO.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

struct GetCurrentCallResponseDTO: Decodable {
    let call: ActiveIncomingRingingCallDTO?
    let pendingIceCandidates: [IceCandidateDTO]
}
