//
//  NetworkError.swift
//  CalloverDesktop
//
//  Created by Leonid  on 04.05.26.
//

enum NetworkError: Error {
    case invalidUrl
    case requestFailed
    case unexpectedResponse(Error?)
    case errorResponse(ErrorResponse)
}
