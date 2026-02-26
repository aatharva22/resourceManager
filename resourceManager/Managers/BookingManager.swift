//
//  BookingManager.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/11/26.
//

import Foundation
import SwiftData

@Observable // @observable, lets you keep an eye on the data changes the ui redraws itself
class BookingManager {
    
    var modelContext : ModelContext // Here we save data from swift data
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    enum BookingError: Error {
        case overlap
        case invalidTime // Start time is after end time
        case timeExceeded
    }
    
    enum TimeLimit {
        case bathroom
        case kitchen
        case TV
        case laundry
        case gym
        
        var minutes: Int {
            switch self {
                case .bathroom: return 30
                case .kitchen: return 45
                case .TV: return 30
                case .laundry: return 120
                case .gym: return 120
                
            }
        }
    }
    
    //Function to check maxTime
    func isDurationValid(start: Date, end: Date, limit: TimeLimit) -> Bool {
            let durationInSeconds = end.timeIntervalSince(start)
            let allowedSeconds = TimeInterval(limit.minutes * 60)
            
            return durationInSeconds <= allowedSeconds
    }
    
    // Function to check conflicts
    func isSlotAvailable(resource: Resource, start: Date, end: Date) -> Bool {
        let existingBookings = fetchBookingsForResource(for: resource)
        
        // Check if the requested range overlaps with any existing range
        for booking in existingBookings {
            // logic: (RequestedStart < ExistingEnd) AND (RequestedEnd > ExistingStart)
            if start < booking.endTime && end > booking.startTime {
                return false // There is an overlap!
            }
        }
        
        return true // No overlaps found
    }
    
    //Function to fetch booking for a specific resource
    func fetchBookingsForResource(for resource : Resource) -> [Booking] {
        
        let resourceId = resource.id
        //Create a predicate
        //Predicate is a where clause in SQL
        let predicate = #Predicate<Booking> {booking in
            resourceId == booking.resource?.id
        }
        
        //Create a fetch descriptor, a select statement
        let descriptor = FetchDescriptor<Booking> (
            predicate: predicate,
            sortBy: [SortDescriptor(\.startTime)] // Order them by time
        )
        
        // Execute the fetch statement, which will fetch the data as per the predicate and the descriptor
        do {
            return try  modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return []
        }
        
    }
    
    func fetchBookingsForUser(for user : String) -> [Booking] {
        
        let userName = user
        
        let predicate = #Predicate<Booking> {booking in
                userName == booking.userName
        }
        
        let descriptor = FetchDescriptor<Booking> (
            predicate : predicate,
            sortBy: [SortDescriptor(\.startTime)]
            )
        
        do {
            return try modelContext.fetch(descriptor)
            } catch {
                print ("Fetch Failed: \(error.localizedDescription)")
                return []
            }
        
        
        
    }
    
    func addBooking(_ resource: Resource, _ start: Date, _ end : Date, _ user : String) throws {
        
        // check start time > end Time
        if start > end {
            throw BookingError.invalidTime
        }
        
        // check for available slot
        guard isSlotAvailable(resource: resource, start: start, end: end) else {
            throw BookingError.overlap
        }
        let limit = resource.timeLimit
        //Check for maxTime
        guard isDurationValid(start: start, end: end, limit: limit) else {
            throw BookingError.timeExceeded
        }
        
        // add Booking
        let newBooking = Booking(startTime: start, endTime: end, userName: user)
        newBooking.resource = resource
        
        modelContext.insert(newBooking)
        
    }
    
    func deleteBooking (_ booking : Booking) {
        modelContext.delete(booking)
    }
    
    func updateBooking(_ booking: Booking, newStart: Date, newEnd: Date) throws {
        // Temporarily ignore THIS booking when checking for conflicts
        let otherBookings = booking.resource?.bookings.filter { $0.id != booking.id } ?? []
        
        let hasOverlap = otherBookings.contains { existing in
            newStart < existing.endTime && newEnd > existing.startTime
        }
        guard let limit = booking.resource?.timeLimit else { throw BookingError.timeExceeded}
        
        guard isDurationValid(start: newStart, end: newEnd, limit: limit) else {
            throw BookingError.timeExceeded
        }
        if hasOverlap {
            throw BookingError.overlap
        }
        
        
        booking.startTime = newStart
        booking.endTime = newEnd
    }
}
