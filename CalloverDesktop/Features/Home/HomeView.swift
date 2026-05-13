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
            VStack(alignment: .leading, spacing: 12) {
                Text("You don't have any contacts yet")
                    .font(.title2)
                    .bold()

                Button {
                } label: {
                    Label("Add Contact", systemImage: "person.badge.plus")
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(32)
    }
}

#Preview {
    HomeView()
}
