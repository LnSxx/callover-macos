//
//  ActiveRemoteCallStatus.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.06.26.
//

enum ActiveRemoteCallStatus: String, Codable {
    case calling
    case ringing
    case active
    
    var callStatus: CallStatus {
        switch self {
        case .calling:
            return .calling
        case .ringing:
            return .ringing
        case .active:
            return .active
        }
    }
}
