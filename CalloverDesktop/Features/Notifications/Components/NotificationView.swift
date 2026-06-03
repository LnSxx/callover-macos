//
//  NotificationView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import SwiftUI

struct NotificationView: View {
    let notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var body: some View {
        switch notification.type {
        case .missedCall where notification.call?.callType != nil && notification.call?.fromUserId != nil:
            MissedCallNotificationView(
                callType: notification.call!.callType,
                callerUserId: notification.call!.fromUserId,
                endedAt: notification.createdAt,
            )
        case .mutedCall where notification.call?.callType != nil && notification.call?.fromUserId != nil:
            MissedCallNotificationView(
                callType: notification.call!.callType,
                callerUserId: notification.call!.fromUserId,
                endedAt: notification.createdAt,
            )
        case .serviceMessage:
            ServiceNotificationView(
                title: notification.title,
                subtitle: notification.body,
                createdAt: notification.createdAt,
            )
        default:
            EmptyView()
        }
    }
}
