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
    var password : String
    init(name: String, password: String) {
        
        self.name = name
        self.password = password
        
    }
}
