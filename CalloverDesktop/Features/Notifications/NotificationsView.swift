//
//  NotificationsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var notificationsViewModel: NotificationsViewModel
    @Environment(\.notificationsService) var notificationsService

    var body: some View {
        VStack(spacing: 0) {
            if notificationsViewModel.notifications.isEmpty {
                ContentUnavailableView(
                    "No Notifications",
                    systemImage: "bell.slash",
                    description: Text("Your notifications will appear here.")
                )
            } else {
                List() {
                    ForEach(notificationsViewModel.notifications) { notification in
                        NotificationView(notification: notification)
                            .tag(notification.id)
                            .listRowSeparator(.hidden)
                            .padding(.vertical, 8)
                            .onAppear {
                                Task {
                                    await notificationsViewModel.fetchNextPageIfNeeded(currentItem: notification)
                                }
                            }
                    }

                    if notificationsViewModel.isLoadingMore {
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
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem {
                Button {
                    Task {
                        await notificationsViewModel.fetchFirstPage()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(notificationsViewModel.isRefreshing)
            }
        }
    }
}

#Preview {
    let remoteResource = RemoteNotificationsService()
    let service = NotificationsService(remoteDataSource: remoteResource)
    let viewModel = NotificationsViewModel(service: service)
    let contactsService = MockContactsService()
    let contactsViewModel = ContactsViewModel(service: contactsService)

    NavigationStack {
        NotificationsView()
            .environmentObject(viewModel)
            .environmentObject(contactsViewModel)
            .environment(\.notificationsService, service)
    }
}
