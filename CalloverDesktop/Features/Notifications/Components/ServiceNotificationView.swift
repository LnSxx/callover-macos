//
//  ServiceNotificationView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 02.06.26.
//

import SwiftUI

struct ServiceNotificationView: View {
    let title: String
    let subtitle: String?
    let createdAt: Date
    
    init(title: String, subtitle: String?, createdAt: Date) {
        self.title = title
        self.subtitle = subtitle
        self.createdAt = createdAt
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(.calloverIcon)
                    .resizable()
                    .frame(width: 40, height: 40)
                
                Text(title)
                    .font(.title)
            }
            
            if let subtitle {
                Text(subtitle)
            }
            
            Text(Self.dateFormatter.string(from: createdAt))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .italic()
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .long
        return formatter
    }()
}

#Preview {
    let title = "Herzliche Wilkommen to Callover!"
    let subtitle = "We hope you enjoy our service. Add contacts and make video and audio calls."
    let createdAt = Date()
    ServiceNotificationView(
        title: title,
        subtitle: subtitle,
        createdAt: createdAt
    )
}
