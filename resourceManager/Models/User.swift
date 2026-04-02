//
//  User.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/27/26.
//

import Foundation
import SwiftData
import CryptoKit

@Model
class User {
    var id : UUID = UUID()
    var name : String
    var passwordHash : String
    init(name: String, password: String) {
        
        self.name = name
        self.passwordHash = User.hash(password)
        
    }
    
    static func hash (_ password : String) -> String{
        let data = Data(password.utf8)
                let digest = SHA256.hash(data: data)
                return digest.map { String(format: "%02x", $0) }.joined()
    }
    func verifyPassword(_ input: String) -> Bool {
            return User.hash(input) == self.passwordHash
        }
}
