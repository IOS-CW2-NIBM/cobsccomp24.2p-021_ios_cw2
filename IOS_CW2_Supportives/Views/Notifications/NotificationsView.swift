// NotificationsView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct NotificationsView: View {
    @StateObject private var viewModel = NotificationsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.notifications.isEmpty {
                    EmptyStateView(icon: "bell.slash.fill",
                                   title: "No Notifications",
                                   message: "You're all caught up! Booking updates will appear here.")
                } else {
                    List {
                        ForEach(viewModel.notifications) { notif in
                            NotificationRow(notification: notif)
                                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12))
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: SPRadius.md)
                                        .fill(notif.isRead ? Color.white : Color.spIndigo.opacity(0.04))
                                        .padding(.vertical, 2)
                                )
                                .onTapGesture { viewModel.markRead(notif.id) }
                        }
                        .onDelete { idx in idx.forEach { viewModel.delete(viewModel.notifications[$0].id) } }
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.spSlate50)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }.foregroundStyle(Color.spIndigo)
                }
                if viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Mark All Read") { viewModel.markAllRead() }
                            .font(SPFont.callout())
                            .foregroundStyle(Color.spIndigo)
                    }
                }
            }
        }
    }
}

// MARK: - Notification row
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: SPSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: notification.type.colorHex).opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: notification.type.colorHex))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(notification.isRead ? SPFont.callout() : SPFont.subheadline())
                        .foregroundStyle(Color.spSlate900)
                        .lineLimit(1)
                    Spacer()
                    if !notification.isRead {
                        Circle().fill(Color.spIndigo).frame(width: 8, height: 8)
                    }
                }
                Text(notification.body)
                    .font(SPFont.footnote())
                    .foregroundStyle(Color.spSlate600)
                    .lineLimit(2)
                Text(notification.createdAt.relative)
                    .font(SPFont.caption())
                    .foregroundStyle(Color.spSlate600.opacity(0.7))
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(notification.title). \(notification.body). \(notification.isRead ? "Read" : "Unread")")
    }
}
