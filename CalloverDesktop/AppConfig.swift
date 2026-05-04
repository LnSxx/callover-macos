//
//  AppConfig.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//


import Foundation

enum AppConfig {
    static var apiBaseURL: URL {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
            let url = URL(string: value)
        else {
            preconditionFailure("API_BASE_URL is not set or invalid")
        }
        return url
    }
}
