//
//  AuthenticatedView.swift
//  CalloverDesktop
//
//  Created by Leonid  on 07.05.26.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject private var contactsViewModel: ContactsViewModel
    
    init(contactsService: ContactsServiceProtocol) {
        let contactsViewModelInstance = ContactsViewModel(
            service: contactsService
        )
        
        _contactsViewModel = StateObject(wrappedValue: contactsViewModelInstance)
    }
    
    var body: some View {
        DashboardView()
            .environmentObject(contactsViewModel)
    }
}
