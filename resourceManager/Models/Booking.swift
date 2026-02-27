//
//  Booking.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/11/26.
//


import Foundation
import SwiftData

@Model
class Booking {
    var id: UUID = UUID()
    var startTime: Date
    var endTime: Date
    var user: User? // Foreign key to the User table
    
    // The "Foreign Key" link back to the Resource table, on the many side of the relationship
    var resource: Resource?
    
    init(startTime: Date, endTime: Date) {
        self.startTime = startTime
        self.endTime = endTime
        
    }
}
