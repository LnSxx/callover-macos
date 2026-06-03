//
//  CallHistoryRow.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import SwiftUI

struct CallHistoryRow: View {
    @EnvironmentObject private var contactsViewModel: ContactsViewModel
    
    let log: CallLog
    
    init(log: CallLog) {
        self.log = log
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .frame(width: 28)
                .foregroundStyle(iconColor)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(directionTitle)
                        .font(.headline)
                    
                    Text(log.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 6) {
                    if log.status != .completed {
                        Text(statusTitle)
                            .font(.subheadline)
                            .foregroundStyle(statusForegroundStyle)
                    }
                    
                    
                    Text(Self.dateFormatter.string(from: log.startedAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let durationSeconds = log.durationSeconds, durationSeconds > 0 {
                Text(formatDuration(durationSeconds))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var contact: Contact? {
        contactsViewModel.contacts.first { $0.contactUserId == log.peerUserId }
    }
    
    private var iconColor: Color {
        switch log.status {
        case .completed:
            return .accent
        case .missed:
            return .red
        case .declined:
            return .red
        case .cancelled:
            return .secondary
        case .noAnswer:
            return .secondary
        case .failed:
            return .red
        }
    }
    
    private var iconName: String {
        switch log.direction {
        case .incoming:
            return log.status == .missed ? "phone.down.fill" : "phone.arrow.down.left.fill"
        case .outgoing:
            return "phone.arrow.up.right.fill"
        }
    }
    
    private var directionTitle: String {
        if let contact {
            return contact.alias ?? contact.displayName
        }
        
        return "@\(log.peerUserId)"
    }
    
    private var statusTitle: String {
        switch log.status {
        case .completed:
            return ""
        case .missed:
            return "Missed"
        case .declined:
            return "Declined"
        case .cancelled:
            return "Cancelled"
        case .noAnswer:
            return "No answer"
        case .failed:
            return "Failed"
        }
    }
    
    private var statusForegroundStyle: some ShapeStyle {
        log.status == .missed ? .red : .secondary
    }
    
    private func formatDuration(_ seconds: Int16) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let hours = minutes / 60
        let seconds = total % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        }
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        
        return "\(seconds)s"
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview(traits: .fixedLayout(width: 400, height: 300)) {
    let logs = MockCallLogsService.previewCallLogs;
    let contactsService = MockContactsService()
    let contactsViewModel = ContactsViewModel(service: contactsService)
    List {
        ForEach(logs) { log in
            CallHistoryRow(log: log)
        }
    }
    .environmentObject(contactsViewModel)
}
