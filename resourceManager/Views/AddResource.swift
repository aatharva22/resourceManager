//
//  AddResource.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/9/26.
//

import Foundation
import SwiftUI
struct AddResource: View {
    
    var house : House
    @State private var selectedName = "kitchen"
    @Binding var isPresented: Bool
    let resourceTypes = ["bathroom", "kitchen", "tvRoom", "laundry", "gym"]
    @Environment(BookingManager.self) private var manager
    

    var body: some View {
        Form {
            VStack {
                Section(header: Text("Select Resource Name")) {
                    Picker("Resource Name", selection: $selectedName) {
                        ForEach(resourceTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    // Options: .menu, .segmented, or .navigationLink
                    .pickerStyle(.menu)
                }
                HStack {
                    Button("Save") {
                        save()
                    }
                    Button("Cancel") {
                        isPresented = false
                    }
                    
                }
                
            }
            
        }
    }
    func save() {
        manager.addResourceToHouse(house: house, resourceName: selectedName)
    }
}

