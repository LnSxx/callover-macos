//
//  Untitled.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import Foundation
import CoreData

protocol LocalCallLogsServiceProtocol {
    func fetchCallLogs() async throws -> [CallLog]
    func upsertCallLogs(_ callLogs: [CallLogDTO]) async throws
    func upsertCallLog(_ callLog: CallLogDTO) async throws
}

final class LocalCallLogsService: LocalCallLogsServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchCallLogs() async throws -> [CallLog] {
        try await context.perform {
            let request: NSFetchRequest<CallLogEntity> = CallLogEntity.fetchRequest()

            request.sortDescriptors = [
                NSSortDescriptor(key: "startedAt", ascending: false),
                NSSortDescriptor(key: "id", ascending: false)
            ]

            let entities = try self.context.fetch(request)

            return try entities.map { try $0.toDomain() }
        }
    }

    func upsertCallLogs(_ callLogs: [CallLogDTO]) async throws {
        try await context.perform {
            for dto in callLogs {
                try self.upsert(dto)
            }

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    func upsertCallLog(_ callLog: CallLogDTO) async throws {
        try await context.perform {
            try self.upsert(callLog)

            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }

    private func upsert(_ dto: CallLogDTO) throws {
        let request: NSFetchRequest<CallLogEntity> = CallLogEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", dto.id)
        request.fetchLimit = 1

        let entity = try context.fetch(request).first ?? CallLogEntity(context: context)

        entity.id = dto.id
        entity.callId = dto.callId
        entity.userId = dto.userId
        entity.peerUserId = dto.peerUserId

        entity.startedAt = try dto.startedAt.toISODate()
        entity.answeredAt = try dto.answeredAt?.toISODate()
        entity.endedAt = try dto.endedAt?.toISODate()

        entity.direction = dto.direction.rawValue
        entity.type = dto.type.rawValue
        entity.status = dto.status.rawValue

        entity.durationSeconds = dto.durationSeconds ?? 0
        entity.ringingDurationSeconds = dto.ringingDurationSeconds ?? 0

        entity.createdAt = try dto.createdAt.toISODate()
    }
}
