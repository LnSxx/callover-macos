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

    var body: some View {
        VStack(spacing: 0) {
            if callHistoryViewModel.logs.isEmpty {
                ContentUnavailableView(
                    "No Call History",
                    systemImage: "phone.down",
                    description: Text("Your calls will appear here.")
                )
            } else {
                List() {
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
        }
    }
}

#Preview {
    let service = MockCallLogsService()
    let contactsService = MockContactsService()
    let viewModel = CallHistoryViewModel(service: service)
    let contactsViewModel = ContactsViewModel(service: contactsService)

    NavigationStack {
        CallHistoryView()
            .environmentObject(viewModel)
            .environmentObject(contactsViewModel)
            .environment(\.callLogsService, service)
    }
}

