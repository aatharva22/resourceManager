import SwiftData
import Foundation
@Model
class Resource {
    var id: UUID = UUID()
    var name: String
    var iconName: String
    var typeRawValue: String // We store this string so SwiftData stays happy
    
    @Relationship(deleteRule: .cascade)
    var bookings: [Booking] = []

    // 💡 Derived property using the Enum
    var timeLimit: BookingManager.TimeLimit {
        // We look at the enum, not the name string!
        switch self.types {
        case .bathroom: return .bathroom
        case .kitchen:  return .kitchen
        case .tvRoom:   return .TV
        case .laundry:  return .laundry
        case .gym:      return .gym
        }
    }

    // This helper property turns typeRawValue back into an Enum for the switch above
    var types: ResourceType {
        get { ResourceType(rawValue: typeRawValue) ?? .kitchen }
        set { typeRawValue = newValue.rawValue }
    }

    init(name: String, iconName: String, type: ResourceType) {
        self.name = name
        self.iconName = iconName
        self.typeRawValue = type.rawValue
    }
}
