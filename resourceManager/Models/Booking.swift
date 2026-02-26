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
    var userName: String
    
    // The "Foreign Key" link back to the Resource table
    var resource: Resource?
    
    init(startTime: Date, endTime: Date, userName: String) {
        self.startTime = startTime
        self.endTime = endTime
        self.userName = userName
    }
}
