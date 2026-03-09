//
//  House_User.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/27/26.
//

import Foundation

import SwiftData

@Model
class House_User {
    var id : UUID = UUID()
    var house : House?
    var user : User?
    var isAdmin : Bool = false
    
    init (isAdmin : Bool) {
        self.isAdmin = isAdmin
    }
    
}
