//
//  CallHistoryView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 01.06.26.
//

import SwiftUI

struct CallHistoryView: View {
    @EnvironmentObject var callHistoryViewModel: CallHistoryViewModel
    @Environment(\.callLogsService) var callLogsService

    @State private var selectedLogId: CallLog.ID?
    @State private var isShowingInspector = true
    @State private var isShowingAddContact = false

    private var selectedLog: CallLog? {
        callHistoryViewModel.logs.first { $0.id == selectedLogId }
    }

    var body: some View {
        VStack(spacing: 0) {
            if callHistoryViewModel.logs.isEmpty {
                ContentUnavailableView(
                    "No Call History",
                    systemImage: "phone.down",
                    description: Text("Your calls will appear here.")
                )
            } else {
                List(selection: $selectedLogId) {
                    ForEach(callHistoryViewModel.logs) { log in
                        CallHistoryRow(log: log)
                            .tag(log.id)
                            .onAppear {
                                Task {
                                    await callHistoryViewModel.fetchNextPageIfNeeded(currentItem: log)
                                }
                            }
                    }

                    if callHistoryViewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .task {
            await callHistoryViewModel.load()
        }
        .navigationTitle("Call History")
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await callHistoryViewModel.fetchRemoteFirstPage()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(callHistoryViewModel.isRefreshing)
            }

            ToolbarItem {
                Button {
                    isShowingInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
            }
        }
        .inspector(isPresented: $isShowingInspector) {
            Group {
                if let selectedLog {
                    CallHistoryInspector(log: selectedLog)
                } else {
                    ContentUnavailableView(
                        "No Call Log Selected",
                        systemImage: "nosign.badge.clock"
                    )
                }
            }
            .inspectorColumnWidth(min: 320, ideal: 360, max: 500)
        }
    }
}

private struct CallHistoryRow: View {
    let log: CallLog

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(directionTitle)
                        .font(.headline)

                    Text(log.type.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 6) {
                    Text(statusTitle)
                        .font(.subheadline)
                        .foregroundStyle(statusForegroundStyle)

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

    private var iconName: String {
        switch log.direction {
        case .incoming:
            return log.status == .missed ? "phone.down.fill" : "phone.arrow.down.left.fill"
        case .outgoing:
            return "phone.arrow.up.right.fill"
        }
    }

    private var directionTitle: String {
        switch log.direction {
        case .incoming:
            return "Incoming"
        case .outgoing:
            return "Outgoing"
        }
    }

    private var statusTitle: String {
        switch log.status {
        case .completed:
            return "Completed"
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
        let seconds = total % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

private struct CallHistoryInspector: View {
    let log: CallLog

    var body: some View {
        Form {
            Section("Call") {
                InspectorRow(title: "ID", value: log.id)
                InspectorRow(title: "Call ID", value: log.callId)
                InspectorRow(title: "User ID", value: log.userId)
                InspectorRow(title: "Peer User ID", value: log.peerUserId)
            }

            Section("Details") {
                InspectorRow(title: "Direction", value: log.direction.rawValue)
                InspectorRow(title: "Type", value: log.type.rawValue)
                InspectorRow(title: "Status", value: statusTitle)
                InspectorRow(title: "Duration", value: formatOptionalDuration(log.durationSeconds))
                InspectorRow(title: "Ringing", value: formatOptionalDuration(log.ringingDurationSeconds))
            }

            Section("Dates") {
                InspectorRow(title: "Started At", value: formatDate(log.startedAt))
                InspectorRow(title: "Answered At", value: formatOptionalDate(log.answeredAt))
                InspectorRow(title: "Ended At", value: formatOptionalDate(log.endedAt))
                InspectorRow(title: "Created At", value: formatDate(log.createdAt))
            }
        }
        .formStyle(.grouped)
    }

    private var statusTitle: String {
        switch log.status {
        case .completed:
            return "Completed"
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

    private func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    private func formatOptionalDate(_ date: Date?) -> String {
        guard let date else {
            return "None"
        }

        return formatDate(date)
    }

    private func formatOptionalDuration(_ seconds: Int16?) -> String {
        guard let seconds else {
            return "None"
        }

        let total = Int(seconds)
        let minutes = total / 60
        let showSeconds = total % 60

        if minutes > 0 {
            return "\(minutes)m \(showSeconds)s"
        }

        return "\(showSeconds)s"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
}

private struct InspectorRow: View {
    let title: String
    let value: String

    var body: some View {
        LabeledContent(title) {
            Text(value)
                .textSelection(.enabled)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    let service = MockCallLogsService()
    let viewModel = CallHistoryViewModel(service: service)

    NavigationStack {
        CallHistoryView()
            .environmentObject(viewModel)
            .environment(\.callLogsService, service)
    }
}

