//
//  AddResource.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/9/26.
//

import Foundation
import SwiftUI
struct AddResource: View {
    
    @State private var selectedType = "kitchen"
    @Binding var isPresented: Bool
    let resourceTypes = ["bathroom", "kitchen", "tvRoom", "laundry", "gym"]

    var body: some View {
        Form {
            VStack {
                Section(header: Text("Select Resource Name")) {
                    Picker("Resource Name", selection: $selectedType) {
                        ForEach(resourceTypes, id: \.self) { type in
                            Text(type)
                        }
                    }
                    // Options: .menu, .segmented, or .navigationLink
                    .pickerStyle(.menu)
                }
                HStack {
                    Button("Save",) {
                        save()
                    }
                }
                
            }
            
        }
    }
    func save() {
        
    }
}
