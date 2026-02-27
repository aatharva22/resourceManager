import SwiftData
import Foundation
@Model
class Resource {
    var id: UUID = UUID()
    var name: String

    // One to many relationship b/w resource and booking
    @Relationship(deleteRule: .cascade)
    var bookings: [Booking] = []
    
    //Foreign key to the house table
    var houseName : House?
    //  Derived property
    var timeLimit: Int {
        // We look at the enum, not the name string!
        switch self.name {
        case "bathroom": return 30
        case "kitchen":  return 45
        case "tvRoom":   return 60
        case "laundry":  return 120
        case "gym":      return 60
        default :        return 30
        }
    }
    var icon: String {
        switch self.name {
        case "bathroom": return "shower"
        case "kitchen":  return "fork.knife"
        case "laundry":  return "washer"
        case "tvRoom":   return "tv"
        case "gym":      return "dumbbell"
        default :        return "questionmark"
        }
    }

   

    init(name: String) {
        self.name = name
        
    }
}
