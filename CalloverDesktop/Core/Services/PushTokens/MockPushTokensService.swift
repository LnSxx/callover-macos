//
//  MockPushTokensService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 12.06.26.
//

struct MockTokensService: PushTokensServiceProtocol {
    func savePushToken(token: String) async throws {}
    
    func deletePushToken(token: String) async throws {}
}
