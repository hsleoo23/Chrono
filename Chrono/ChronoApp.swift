//
//  ChronoApp.swift
//  Chrono
//
//  Created by 韩澍 on 2025/6/11.
//

import SwiftUI

@main
struct ChronoApp: App {
    @StateObject var store = ScheduleStore()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
