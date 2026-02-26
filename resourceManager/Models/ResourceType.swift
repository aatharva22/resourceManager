//
//  ResourceType.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/20/26.
//

import Foundation

enum ResourceType: String, CaseIterable {
    case bathroom = "Bathroom"
    case kitchen = "Kitchen"
    case laundry = "Laundry"
    case tvRoom = "TV Room"
    case gym = "Gym"
    
    // We can also put the icons here so they are always linked to the type
    var icon: String {
        switch self {
        case .bathroom: return "shower"
        case .kitchen:  return "fork.knife"
        case .laundry:  return "washer"
        case .tvRoom:   return "tv"
        case .gym:      return "dumbbell"
        }
    }
}
