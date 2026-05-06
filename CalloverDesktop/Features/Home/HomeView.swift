//
//  HomeView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 06.05.26.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Callover")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 16) {
                StatCard(title: "Missed Calls", value: "0", icon: "phone.down")
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Actions")
                    .font(.title2)
                    .bold()

                HStack {
                    Button {
                        // Start call
                    } label: {
                        Label("New Call", systemImage: "phone.fill")
                    }

                    Button {
                        // Open contacts
                    } label: {
                        Label("Add Contact", systemImage: "person.badge.plus")
                    }
                }
            }

            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    HomeView()
}
