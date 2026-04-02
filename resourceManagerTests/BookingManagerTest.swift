//
//  BookingManagerTest.swift
//  resourceManagerTests
//
//  Created by Atharva Sonawane on 2/11/26.
//

import Testing
import SwiftData
import Foundation
@testable import resourceManager // This allows the test to see your app's code

struct BookingManagerTest {

    @Test func testConflictDetection() throws {
        // 1. Setup a "Fake" in-memory database
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Resource.self, Booking.self, configurations: config)
        let context = ModelContext(container)
        
        // 2. Initialize your Manager
        let manager = BookingManager(modelContext: context)
        
        // 3. Create a Resource and a base Booking
        let kitchen = Resource(name: "Kitchen")
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour later
        
        // 4. Manually add a booking
        let existingBooking = Booking(startTime: startTime, endTime: endTime)
        existingBooking.resource = kitchen
        context.insert(existingBooking)
        
        // 5. THE TEST: Try to book a slot that overlaps
        let isAvailable = manager.isSlotAvailable(
            resource: kitchen, user: manager.currentUser!,
            start: startTime.addingTimeInterval(1800), // Starts 30 mins into the first booking
            end: endTime.addingTimeInterval(1800)
        )
        
        // 6. Assert that it SHOULD be false
        #expect(isAvailable == false)
    }
}
