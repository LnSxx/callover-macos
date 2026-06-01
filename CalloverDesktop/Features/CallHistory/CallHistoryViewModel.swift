//
//  CallHistoryViewModel.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation
import Combine

@MainActor
final class CallHistoryViewModel: ObservableObject {
    @Published private(set) var logs: [CallLog] = []
    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var nextCursor: String?
    @Published var errorMessage: String?

    private let service: CallLogsServiceProtocol
    private var hasLoaded = false

    init(service: CallLogsServiceProtocol) {
        self.service = service
    }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        await loadLocalLogs()
        await fetchRemoteFirstPage()
    }

    func loadLocalLogs() async {
        do {
            logs = try await service.loadLocalCallLogs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchRemoteFirstPage() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            errorMessage = nil

            let cursor = try await service.fetchFirstPageOfLogs()
            nextCursor = cursor

            logs = try await service.loadLocalCallLogs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchNextPage() async {
        guard !isLoadingMore else { return }
        guard let cursor = nextCursor, !cursor.isEmpty else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            errorMessage = nil

            let cursor = try await service.fetchNextPageOfLogs(cursor: cursor)
            nextCursor = cursor

            logs = try await service.loadLocalCallLogs()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchNextPageIfNeeded(currentItem: CallLog?) async {
        guard let currentItem else { return }

        let thresholdIndex = logs.index(logs.endIndex, offsetBy: -5, limitedBy: logs.startIndex) ?? logs.startIndex

        guard logs.indices.contains(thresholdIndex) else { return }

        let thresholdItem = logs[thresholdIndex]

        if currentItem.id == thresholdItem.id {
            await fetchNextPage()
        }
    }
}
