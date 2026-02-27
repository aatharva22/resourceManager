//
//  User.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/27/26.
//

import Foundation
import SwiftData

@Model
class User {
    var id : UUID = UUID()
    var name : String
    
    init(name: String) {
        
        self.name = name
    }
}
