//
//  AppDeviceInfoProvider.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

import Foundation

struct AppDeviceInfo {
    let bundleId: String
    let appVersion: String
}

enum AppDeviceInfoProvider {
    static var current: AppDeviceInfo {
        AppDeviceInfo(
            bundleId: bundleId,
            appVersion: appVersion
        )
    }
    
    private static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "unknown"
    }
    
    private static var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        
        return "\(version)(\(build))"
    }
}
