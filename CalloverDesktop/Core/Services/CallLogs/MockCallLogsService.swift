//
//  MockCallLogsService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

final class MockCallLogsService: CallLogsServiceProtocol {
    private var localCallLogs: [CallLog]
    private let remotePages: [[CallLog]]
    private var loadedPageIndex = 0
    
    init(
        localCallLogs: [CallLog] = MockCallLogsService.previewCallLogs,
        remotePages: [[CallLog]] = [
            MockCallLogsService.previewCallLogs,
            MockCallLogsService.olderPreviewCallLogs
        ]
    ) {
        self.localCallLogs = localCallLogs
        self.remotePages = remotePages
    }
    
    func loadLocalCallLogs() async throws -> [CallLog] {
        localCallLogs.sorted { $0.startedAt > $1.startedAt }
    }
    
    func fetchFirstPageOfLogs() async throws -> String? {
        loadedPageIndex = 0
        
        guard !remotePages.isEmpty else {
            localCallLogs = []
            return nil
        }
        
        upsert(remotePages[0])
        
        return remotePages.count > 1 ? "mock-cursor-1" : nil
    }
    
    func fetchNextPageOfLogs(cursor: String) async throws -> String? {
        guard !cursor.isEmpty else {
            return nil
        }
        
        let nextPageIndex = loadedPageIndex + 1
        
        guard remotePages.indices.contains(nextPageIndex) else {
            return nil
        }
        
        loadedPageIndex = nextPageIndex
        
        upsert(remotePages[nextPageIndex])
        
        let hasNextPage = remotePages.indices.contains(nextPageIndex + 1)
        
        return hasNextPage ? "mock-cursor-\(nextPageIndex + 1)" : nil
    }
    
    private func upsert(_ callLogs: [CallLog]) {
        var dictionary = Dictionary(
            uniqueKeysWithValues: localCallLogs.map { ($0.id, $0) }
        )
        
        for callLog in callLogs {
            dictionary[callLog.id] = callLog
        }
        
        localCallLogs = dictionary.values.sorted { $0.startedAt > $1.startedAt }
    }
}

extension MockCallLogsService {
    static let previewCallLogs: [CallLog] = [
        CallLog(
            id: "call-log-1",
            callId: "call-1",
            userId: "current-user-id",
            peerUserId: "peer-user-1",
            startedAt: Date().addingTimeInterval(-60 * 5),
            answeredAt: Date().addingTimeInterval(-60 * 5 + 5),
            endedAt: Date().addingTimeInterval(-60 * 2),
            direction: .outgoing,
            type: .video,
            status: .completed,
            durationSeconds: 175,
            ringingDurationSeconds: 5,
            createdAt: Date().addingTimeInterval(-60 * 5)
        ),
        CallLog(
            id: "call-log-2",
            callId: "call-2",
            userId: "current-user-id",
            peerUserId: "peer-user-2",
            startedAt: Date().addingTimeInterval(-60 * 45),
            answeredAt: nil,
            endedAt: Date().addingTimeInterval(-60 * 44),
            direction: .incoming,
            type: .audio,
            status: .missed,
            durationSeconds: nil,
            ringingDurationSeconds: 60,
            createdAt: Date().addingTimeInterval(-60 * 45)
        ),
        CallLog(
            id: "call-log-3",
            callId: "call-3",
            userId: "current-user-id",
            peerUserId: "peer-user-3",
            startedAt: Date().addingTimeInterval(-60 * 60 * 3),
            answeredAt: nil,
            endedAt: Date().addingTimeInterval(-60 * 60 * 3 + 20),
            direction: .outgoing,
            type: .video,
            status: .cancelled,
            durationSeconds: nil,
            ringingDurationSeconds: 20,
            createdAt: Date().addingTimeInterval(-60 * 60 * 3)
        ),
        CallLog(
            id: "call-log-4",
            callId: "call-4",
            userId: "current-user-id",
            peerUserId: "peer-user-4",
            startedAt: Date().addingTimeInterval(-60 * 60 * 8),
            answeredAt: Date().addingTimeInterval(-60 * 60 * 8 + 4),
            endedAt: Date().addingTimeInterval(-60 * 60 * 8 + 420),
            direction: .incoming,
            type: .audio,
            status: .completed,
            durationSeconds: 416,
            ringingDurationSeconds: 4,
            createdAt: Date().addingTimeInterval(-60 * 60 * 8)
        )
    ]
    
    static let olderPreviewCallLogs: [CallLog] = [
        CallLog(
            id: "call-log-5",
            callId: "call-5",
            userId: "current-user-id",
            peerUserId: "peer-user-5",
            startedAt: Date().addingTimeInterval(-60 * 60 * 24),
            answeredAt: nil,
            endedAt: Date().addingTimeInterval(-60 * 60 * 24 + 30),
            direction: .incoming,
            type: .video,
            status: .declined,
            durationSeconds: nil,
            ringingDurationSeconds: 30,
            createdAt: Date().addingTimeInterval(-60 * 60 * 24)
        ),
        CallLog(
            id: "call-log-6",
            callId: "call-6",
            userId: "current-user-id",
            peerUserId: "peer-user-6",
            startedAt: Date().addingTimeInterval(-60 * 60 * 30),
            answeredAt: nil,
            endedAt: Date().addingTimeInterval(-60 * 60 * 30 + 10),
            direction: .outgoing,
            type: .audio,
            status: .failed,
            durationSeconds: nil,
            ringingDurationSeconds: 10,
            createdAt: Date().addingTimeInterval(-60 * 60 * 30)
        )
    ]
}
