//
//  BookingManager.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/11/26.
//

import Foundation
import SwiftData
import _SwiftData_SwiftUI

@Observable // @observable, lets you keep an eye on the data changes the ui redraws itself
class BookingManager {
    
    var currentUser : User?
    var modelContext : ModelContext // Here we save data from swift data
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    enum BookingError: Error {
        case overlap
        case invalidTime // Start time is after end time
        case timeExceeded
        case alreadyExists
    }
    
    
    
    //Function to check maxTime
    func isDurationValid(start: Date, end: Date, limit: Int) -> Bool {
        let durationInSeconds = end.timeIntervalSince(start)
        let allowedSeconds = TimeInterval(limit  * 60)
        
        return durationInSeconds <= allowedSeconds
    }
    
    // Function to check conflicts
    func isSlotAvailable(resource: Resource, user: User, start: Date, end: Date) -> Bool {
        // 1. Check if the User has a conflict
        let userBookings = fetchBookingsForUser(user: user)
        if userBookings.contains(where: { start <= $0.endTime && end >= $0.startTime }) {
            return false
        }
        
        // 2. Check if the Resource has a conflict (with anyone else)
        let resourceBookings = resource.bookings  
        if resourceBookings.contains(where: { start < $0.endTime && end > $0.startTime }) {
            return false
        }
        
        return true
    }
    
    func fetchBookingsForUser(user: User) -> [Booking] {
        // Get the ID first to keep the Predicate happy
        let userID = user.persistentModelID
        
        // Tell the database to ONLY give us this user's bookings
        let predicate = #Predicate<Booking> { booking in
            booking.user?.persistentModelID == userID
        }
        
        let descriptor = FetchDescriptor<Booking>(predicate: predicate)
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed \(error)")
            return []
        }
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
            userName == booking.user?.name
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
    
    func addBooking(_ resource: Resource, _ start: Date, _ end : Date,  user : User) throws {
        
        // check start time > end Time
        if start > end {
            throw BookingError.invalidTime
        }
        
        // check for available slot
        guard isSlotAvailable(resource: resource, user:user, start: start, end: end) else {
            throw BookingError.overlap
        }
        let limit = resource.timeLimit
        //Check for maxTime
        guard isDurationValid(start: start, end: end, limit: limit) else {
            throw BookingError.timeExceeded
        }
        
        // add Booking
        let newBooking = Booking(startTime: start, endTime: end)
        newBooking.resource = resource
        newBooking.user = user
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
    //login
    func checkLogin(userName: String, password: String) -> Bool {
        // Only query by username — NEVER query by password directly
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.name == userName }
        )
        do {
            let foundUsers = try modelContext.fetch(descriptor)
            if let user = foundUsers.first, user.verifyPassword(password) {
                self.currentUser = user
                return true
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
        }
        return false
    }
    
    //register
    func signUp(userName: String, password: String) -> Bool {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.name == userName }
        )
        do {
            let foundUsers = try modelContext.fetch(descriptor)
            if foundUsers.isEmpty {
                let newUser = User(name: userName, password: password)
                // User.init() hashes the password internally — nothing else to do
                modelContext.insert(newUser)
                try modelContext.save()
                self.currentUser = newUser
                return true
            } else {
                print("User already exists")
                return false
            }
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
    //sign out
    func signOut() {
        currentUser = nil
    }
    //prints all users
    func debugCheckUsers() {
        let descriptor = FetchDescriptor<User>() // "Get everything of type User"
        do {
            let allUsers = try modelContext.fetch(descriptor)
            print("--- Current Users in Database ---")
            for user in allUsers {
                print("ID: \(user.id), Name: \(user.name)")
            }
        } catch {
            print("Fetch failed")
        }
    }
    
    //create house
    func createHouse(name:String) -> String{
        guard let user = currentUser else { return "not logged In"}
        let descriptor = FetchDescriptor<House>(
            predicate: #Predicate { $0.name == name }
        )
        do {
            let foundHouse  = try modelContext.fetch(descriptor)
            if foundHouse.isEmpty {
                let newHouse = House(name: name)
                modelContext.insert(newHouse)
                
                let bridge = House_User(isAdmin: true)
                bridge.user = user
                bridge.house = newHouse
                modelContext.insert(bridge)
                
                try modelContext.save()
            }
            else {
                print("House already exists")
                return("House already exists")
            }
        }
        catch {
            print ("fetch Error")
            return("fetch error")
        }
        print("Success")
        return ("Success")
    }
    
    //Adding user to the house_user model
    func addUserToHouse(userName: String, house: House) -> String {
        // 1. Check if this specific user is ALREADY in this specific house
        let houseId = house.id
        let bridgeDescriptor = FetchDescriptor<House_User>(
            predicate: #Predicate { $0.user?.name == userName && $0.house?.id == houseId }
        )
        
        do {
            let existingBridges = try modelContext.fetch(bridgeDescriptor)
            if !existingBridges.isEmpty {
                return "User already added to the house"
            }
            
            // 2. Find the actual User object in the system
            let userDescriptor = FetchDescriptor<User>(
                predicate: #Predicate { $0.name == userName }
            )
            let foundUsers = try modelContext.fetch(userDescriptor)
            
            // FIX: Check if it IS empty to return the error
            if foundUsers.isEmpty {
                return "No user exists with the given userName"
            }
            
            // 3. Create the bridge
            if let userToLink = foundUsers.first {
                let bridge = House_User(isAdmin: false)
                bridge.user = userToLink
                bridge.house = house // Ensure this matches your model property name
                
                modelContext.insert(bridge)
                try modelContext.save()
                
                return "User successfully added to the house"
            }
            
        } catch {
            return "System error: \(error.localizedDescription)"
        }
        
        return "Unknown error occurred"
    }
    
    func isCurrentUserAdmin(of house: House) -> Bool {
        let houseId = house.id
        
        // Ensure currentUser is not nil before querying
        guard let currentUserName = currentUser?.name else { return false }

        let descriptor = FetchDescriptor<House_User>(
            predicate: #Predicate { $0.user?.name == currentUserName && $0.house?.id == houseId }
        )
        
        do {
            let foundPairs = try modelContext.fetch(descriptor)
            
            // Use optional chaining and nil-coalescing safely
            return foundPairs.first?.isAdmin ?? false
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func fetchMyHouses() -> [House] {
        guard let user = currentUser else { return [] }
        
        let targetUserID = user.persistentModelID
        
        let descriptor = FetchDescriptor<House_User>(
            //            predicate: #Predicate<House_User> { bridge in
            //
            //                bridge.user != nil && bridge.user!.persistentModelID == targetUserID
            //            }
        )
        
        do {
            let pairs = try modelContext.fetch(descriptor)
            
            return pairs.filter{$0.user?.persistentModelID == targetUserID}.compactMap{$0.house}
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }
    
    func fetchResourcesForHouse (house:House) -> [Resource] {
        let descriptor = FetchDescriptor<Resource>()
        do {
            let resources = try modelContext.fetch(descriptor)
            return resources.filter{ $0.houseName == house}
            
        } catch {
            print("Fetch failed \(error)")
            return []
        }
        
    }
    
    func addResourceToHouse(house : House, resourceName:String) {
        let newResource = Resource(name: resourceName)
        newResource.houseName = house
        
        modelContext.insert(newResource)
    }
    
}
