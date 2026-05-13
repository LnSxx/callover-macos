//
//  ContactAvatar.swift
//  CalloverDesktop
//
//  Created by Leonid  on 13.05.26.
//

import SwiftUI

struct ContactAvatar: View {
    enum Variant {
        case small
        case medium
        case large
        
        var size: CGFloat {
            switch self {
            case .small:
                return 34
            case .medium:
                return 52
            case .large:
                return 76
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small:
                return 14
            case .medium:
                return 20
            case .large:
                return 28
            }
        }
    }
    
    private let initial: String?
    private let variant: Variant
    
    init(
        initial: String?,
        variant: Variant = .large,
    ) {
        self.initial = initial
        self.variant = variant
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            
            if let initial {
                Text(String(initial.prefix(1)).uppercased())
                    .font(.system(size: variant.fontSize, weight: .semibold))
                    .foregroundStyle(.primary)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: variant.fontSize))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(
            width: variant.size,
            height: variant.size,
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        ContactAvatar(
            initial: "User",
            variant: .small,
        )
        
        ContactAvatar(
            initial: "Callover",
            variant: .medium,
        )
        
        ContactAvatar(
            initial: nil,
            variant: .large,
        )
    }
    .padding()
}
