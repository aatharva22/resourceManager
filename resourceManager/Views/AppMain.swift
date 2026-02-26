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
            ResourceListView()
        }
        .modelContainer(for: [Resource.self, Booking.self])
    }
}
#Preview {
    // This tells the canvas which view to draw
    ResourceListView()
        .modelContainer(for: [Resource.self, Booking.self], inMemory: true)
}
