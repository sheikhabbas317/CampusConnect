//
//  CampusConnectAppApp.swift
//  CampusConnectApp
//
//  Created by Muhammad Abbas on 26/12/2025.
//

import SwiftUI

@main
struct CampusConnectAppApp: App {
    @StateObject private var store = MockDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
