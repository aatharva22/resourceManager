//
//  BookingManagerTests.swift
//  resourceManagerTests
//
//  Created by Atharva Sonawane on 4/2/26.
//

import Testing
import SwiftData
@testable import resourceManager
import Foundation

// @Suite groups related tests together
// Each test gets a FRESH manager via the helper — no shared state
@Suite("BookingManager Tests")
struct BookingManagerTests {

    // ── Helpers ──────────────────────────────────────────────────────────────

    // Creates a clean in-memory manager for every test
    func makeManager() throws -> BookingManager {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: User.self, Booking.self, Resource.self, House.self, House_User.self,
            configurations: config
        )
        return BookingManager(modelContext: ModelContext(container))
    }

    // Builds two non-overlapping time slots from now
    // slot 1: now+0h → now+1h
    // slot 2: now+2h → now+3h
    func makeTimes() -> (Date, Date, Date, Date) {
        let base = Date()
        return (
            base,
            base.addingTimeInterval(3600),   // +1h
            base.addingTimeInterval(7200),   // +2h
            base.addingTimeInterval(10800)   // +3h
        )
    }

    // ── Auth Tests ────────────────────────────────────────────────────────────

    @Test("Sign up creates a new user")
    func testSignUp() throws {
        let manager = try makeManager()
        let success = manager.signUp(userName: "atharva", password: "secret")
        #expect(success == true)
        #expect(manager.currentUser?.name == "atharva")
    }

    @Test("Sign up fails for duplicate username")
    func testSignUpDuplicate() throws {
        let manager = try makeManager()
        manager.signUp(userName: "atharva", password: "secret")
        let duplicate = manager.signUp(userName: "atharva", password: "other")
        #expect(duplicate == false)
    }

    @Test("Login succeeds with correct password")
    func testLoginSuccess() throws {
        let manager = try makeManager()
        manager.signUp(userName: "atharva", password: "secret")
        manager.signOut()
        let loggedIn = manager.checkLogin(userName: "atharva", password: "secret")
        #expect(loggedIn == true)
        #expect(manager.currentUser != nil)
    }

    @Test("Login fails with wrong password")
    func testLoginWrongPassword() throws {
        let manager = try makeManager()
        manager.signUp(userName: "atharva", password: "secret")
        manager.signOut()
        let loggedIn = manager.checkLogin(userName: "atharva", password: "wrong")
        #expect(loggedIn == false)
        #expect(manager.currentUser == nil)
    }

    @Test("Sign out clears current user")
    func testSignOut() throws {
        let manager = try makeManager()
        manager.signUp(userName: "atharva", password: "secret")
        manager.signOut()
        #expect(manager.currentUser == nil)
    }

    // ── Booking — Happy Path ──────────────────────────────────────────────────

    @Test("Successful booking is added")
    func testSuccessfulBooking() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let resource = Resource(name: "gym")
        let (s, e, _, _) = makeTimes()

        try manager.addBooking(resource, s, e, user: user)

        #expect(resource.bookings.count == 1)
        #expect(resource.bookings.first?.user?.name == "atharva")
    }

    @Test("Delete booking removes it from resource")
        func testDeleteBooking() throws {
            let manager = try makeManager()
            let user = User(name: "atharva", password: "secret")
            let resource = Resource(name: "gym")
            let (s, e, _, _) = makeTimes()

            try manager.addBooking(resource, s, e, user: user)
            let booking = resource.bookings.first!
            manager.deleteBooking(booking)

            // SwiftData caches relationships in memory — we need to save
            // and re-fetch to see the updated state reflected on the object
            try manager.modelContext.save()
            let freshBookings = manager.fetchBookingsForResource(for: resource)
            #expect(freshBookings.isEmpty)
        }

    @Test("Update booking changes times successfully")
    func testUpdateBooking() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let resource = Resource(name: "gym")
        let (s, e, newS, newE) = makeTimes()

        try manager.addBooking(resource, s, e, user: user)
        let booking = resource.bookings.first!
        try manager.updateBooking(booking, newStart: newS, newEnd: newE)

        #expect(booking.startTime == newS)
        #expect(booking.endTime == newE)
    }

    // ── Booking — Error Cases ─────────────────────────────────────────────────

    @Test("Throws invalidTime when start is after end")
    func testInvalidTime() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let resource = Resource(name: "gym")
        let (s, e, _, _) = makeTimes()

        // Intentionally swap start and end
        #expect(throws: BookingManager.BookingError.invalidTime) {
            try manager.addBooking(resource, e, s, user: user) // e > s → invalid
        }
    }

    @Test("Throws overlap when resource is already booked")
    func testConflictDetection() throws {
        let manager = try makeManager()
        let user1 = User(name: "user1", password: "pass")
        let user2 = User(name: "user2", password: "pass")
        let resource = Resource(name: "gym")
        let (s, e, _, _) = makeTimes()

        try manager.addBooking(resource, s, e, user: user1)

        // user2 tries to book the exact same slot
        #expect(throws: BookingManager.BookingError.overlap) {
            try manager.addBooking(resource, s, e, user: user2)
        }
    }

    @Test("Throws overlap when user already has a booking in that window")
    func testUserConflict() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let gym = Resource(name: "gym")
        let laundry = Resource(name: "laundry")
        let (s, e, _, _) = makeTimes()

        try manager.addBooking(gym, s, e, user: user)

        // Same user, different resource, same time — still a conflict
        #expect(throws: BookingManager.BookingError.overlap) {
            try manager.addBooking(laundry, s, e, user: user)
        }
    }

    @Test("Throws timeExceeded when booking exceeds resource limit")
    func testTimeLimitExceeded() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let resource = Resource(name: "bathroom") // 30 min limit

        let start = Date()
        let end = start.addingTimeInterval(3600) // 60 min — over the 30 min limit

        #expect(throws: BookingManager.BookingError.timeExceeded) {
            try manager.addBooking(resource, start, end, user: user)
        }
    }

    @Test("Throws overlap when update conflicts with another booking")
    func testUpdateBookingConflict() throws {
        let manager = try makeManager()
        let user = User(name: "atharva", password: "secret")
        let resource = Resource(name: "gym")
        let (s, e, newS, newE) = makeTimes()

        // Book slot 1 and slot 2
        try manager.addBooking(resource, s, e, user: user)
        let user2 = User(name: "user2", password: "pass")
        try manager.addBooking(resource, newS, newE, user: user2)

        // Try to move slot 1 to overlap with slot 2
        let booking1 = resource.bookings.first!
        #expect(throws: BookingManager.BookingError.overlap) {
            try manager.updateBooking(booking1, newStart: newS, newEnd: newE)
        }
    }
}
