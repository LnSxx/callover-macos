//
//  NotificationsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import Foundation

protocol NotificationsServiceProtocol {
    func fetchFirstPage() async throws -> NotificationsFetchResult
    func fetchNextPage(next: String) async throws -> NotificationsFetchResult
}

struct NotificationsFetchResult {
    let data: [Notification]
    let next: String?
    let totalUnreadCount: Int
}

final class NotificationsService: NotificationsServiceProtocol {
    private enum Constants {
        static let pageLimit = 100
    }
    
    private let remoteDataSource: RemoteNotificationsServiceProtocol
    
    init(
        remoteDataSource: RemoteNotificationsServiceProtocol,
    ) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchFirstPage() async throws -> NotificationsFetchResult {
        let page = try await remoteDataSource.fetchNotifications(
            limit: Constants.pageLimit,
            offset: 0,
            status: nil,
        )
        
        return NotificationsFetchResult(
            data: try page.data.map { try $0.toDomain() },
            next: page.pagination.next,
            totalUnreadCount: page.totalUnreadCount,
        )
    }
    
    func fetchNextPage(next: String) async throws -> NotificationsFetchResult {
        let page = try await remoteDataSource.fetchNextNotifications(next: next)
        
        return NotificationsFetchResult(
            data: try page.data.map { try $0.toDomain() },
            next: page.pagination.next,
            totalUnreadCount: page.totalUnreadCount,
        )
    }
}
