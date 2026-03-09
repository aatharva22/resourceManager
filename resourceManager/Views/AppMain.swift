//
//  AppMain.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/20/26.
//

import SwiftUI
import SwiftData



@main
struct ResourceManagerApp : App {
    var body: some Scene {
        WindowGroup {
            // No need to pass context here anymore
            RootView()
        }
        // This creates the context for RootView to find later
        .modelContainer(for: [Resource.self, Booking.self, User.self, House.self, House_User.self])
    }
}
//#Preview {
//    // This tells the canvas which view to draw
//    ResourceListView()
//        .modelContainer(for: [Resource.self, Booking.self, House.self], inMemory: true)
//}
