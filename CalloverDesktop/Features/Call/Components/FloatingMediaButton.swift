//
//  FloatingMediaButton.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.05.26.
//

import SwiftUI

struct FloatingMediaButton: View {
    let systemName: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .frame(width: 58, height: 58)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .shadow(radius: 12)
        }
        .buttonStyle(.plain)
    }
}
