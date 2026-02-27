//
//  ResourceDatailView.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/26/26.
//

import Foundation
import SwiftUI
import SwiftData

struct ResourceDetailView: View {
    
    let resource:Resource
    
    var body : some View {
        VStack{
            Text("\(resource.name)")
            Image(systemName: resource.icon)
                
            
        }
    }
    
}

#Preview {
    let kitchen = Resource(name: "kitchen")
    ResourceDetailView(resource: kitchen)
}

