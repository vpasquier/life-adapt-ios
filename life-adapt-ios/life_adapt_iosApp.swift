//
//  life_adapt_iosApp.swift
//  life-adapt-ios
//
//  Created by Vladimir Pasquier on 3/22/24.
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
