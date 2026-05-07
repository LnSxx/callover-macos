//
//  ContactsView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject var viewModel: ContactsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            
            if viewModel.contacts.isEmpty {
                emptyState
            } else {
                contactsList
            }
        }
        .padding(32)
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Contacts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(viewModel.contacts.count) contacts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if viewModel.isSyncing {
                ProgressView()
                    .controlSize(.small)
            }
            
            Button {
                Task {
                    await viewModel.sync()
                }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.isSyncing)
        }
    }
    
    private var contactsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.contacts) { contact in
                    ContactRowView(contact: contact)
                }
            }
            .padding(.top, 4)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text("No contacts yet")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Your contacts will appear here after sync.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if viewModel.isSyncing {
                ProgressView()
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ContactRowView: View {
    let contact: Contact
    
    var body: some View {
        HStack(spacing: 14) {
            avatar
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(displayName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if contact.isFavourite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                    
                    if contact.isMuted {
                        Image(systemName: "bell.slash.fill")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    
                    if contact.isBlocked {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                Text(contact.contactUserId)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if let note = contact.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(contact.updatedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(contact.updatedAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            
            Text(initials)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(width: 48, height: 48)
    }
    
    private var displayName: String {
        if let alias = contact.alias, !alias.isEmpty {
            return alias
        }
        
        return "Unknown Contact"
    }
    
    private var initials: String {
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let first = name.first else {
            return "?"
        }
        
        return String(first).uppercased()
    }
}

#Preview {
    let remoteDataSource = RemoteContactsService()
    let localDataSource = LocalContactsService(context: PersistenceController.shared.viewContext)
    let syncState = SyncStateService(context: PersistenceController.shared.viewContext)
    let service = ContactsService(
        remoteDataSource: remoteDataSource, localDataSource: localDataSource, syncStateService: syncState
    )
    let viewModel = ContactsViewModel(service: service)
    ContactsView()
        .environmentObject(viewModel)
}
