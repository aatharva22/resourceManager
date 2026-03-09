//
//  House.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/27/26.
//

import Foundation
import SwiftData

@Model
class House : Identifiable {
    var id : UUID = UUID()
    var name : String
    
    @Relationship(deleteRule: .cascade) var Resources : [Resource] = []
    
    

    init( name: String) {
        self.name = name
    }
}
