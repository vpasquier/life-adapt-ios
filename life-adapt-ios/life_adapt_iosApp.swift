//
//  life_adapt_iosApp.swift
//  life-adapt-ios
//

import SwiftUI

@main
struct life_adapt_iosApp: App {
    @StateObject var coordinator = Coordinator()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
        }
    }
}
