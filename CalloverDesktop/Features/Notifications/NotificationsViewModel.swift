//
//  NotificationsViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import Foundation
import Combine

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private(set) var notifications: [Notification] = []
    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var next: String?
    @Published private(set) var unreadCount: Int?
    @Published var errorMessage: String?
    
    private let service: NotificationsServiceProtocol
    private var hasLoaded = false
    
    init(service: NotificationsServiceProtocol) {
        self.service = service
        Task {
            await load()
        }
    }
    
    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        
        await fetchFirstPage()
    }
    
    func fetchFirstPage() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        do {
            errorMessage = nil
            
            let result = try await service.fetchFirstPage()
            
            notifications = result.data
            next = result.next
            unreadCount = result.totalUnreadCount
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchNextPage() async {
        guard !isLoadingMore else { return }
        guard let nextPage = next, !nextPage.isEmpty else { return }
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            errorMessage = nil
            
            let nextPage = try await service.fetchNextPage(next: nextPage)
            
            notifications.append(contentsOf: nextPage.data)
            next = nextPage.next
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchNextPageIfNeeded(currentItem: Notification?) async {
        guard let currentItem else { return }
        
        let thresholdIndex = notifications.index(
            notifications.endIndex,
            offsetBy: -5,
            limitedBy: notifications.startIndex
        ) ?? notifications.startIndex
        
        guard notifications.indices.contains(thresholdIndex) else { return }
        
        let thresholdItem = notifications[thresholdIndex]
        
        if currentItem.id == thresholdItem.id {
            await fetchNextPage()
        }
    }
}
