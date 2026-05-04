//
//  AuthLoadingView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 20.04.26.
//

import SwiftUI

struct AuthLoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Calling for profile...").padding()
        }.padding(50)
    }
}

#Preview {
    AuthLoadingView()
}
