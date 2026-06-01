//
//  CallHistoryService.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation

protocol CallLogsServiceProtocol {
    func loadLocalCallLogs() async throws -> [CallLog]
    func fetchFirstPageOfLogs() async throws -> String?
    func fetchNextPageOfLogs(cursor: String) async throws -> String?
}

final class CallLogsService: CallLogsServiceProtocol {
    private enum Constants {
        static let pageLimit = 100
    }
    
    
    private let remoteDataSource: RemoteCallLogsServiceProtocol
    private let localDataSource: LocalCallLogsServiceProtocol
    
    init(
        remoteDataSource: RemoteCallLogsServiceProtocol,
        localDataSource: LocalCallLogsServiceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func loadLocalCallLogs() async throws -> [CallLog] {
        return try await localDataSource.fetchCallLogs()
    }
    
    func fetchFirstPageOfLogs() async throws -> String? {
        let page = try await remoteDataSource.fetchCallLogs(
            limit: Constants.pageLimit,
            cursor: nil
        )
        
        try await localDataSource.upsertCallLogs(page.data)
        
        return page.nextCursor
    }
    
    func fetchNextPageOfLogs(cursor: String) async throws -> String? {
        guard !cursor.isEmpty else {
            return nil
        }
        
        let page = try await remoteDataSource.fetchCallLogs(
            limit: Constants.pageLimit,
            cursor: cursor
        )
        
        try await localDataSource.upsertCallLogs(page.data)
        
        return page.nextCursor
    }
}
