//
//  AddUserToHouse.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/5/26.
//
import SwiftUI

struct AddMemberSheet: View {
    var house: House
    @Environment(BookingManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State private var userNameToSearch: String = ""
    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Add a member to \(house.name)")
                    .font(.headline)
                
                TextField("Enter exact username", text: $userNameToSearch)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .foregroundColor(isSuccess ? .green : .red)
                        .font(.caption)
                }
                
                Button("Add to House") {
                    let result = manager.addUserToHouse(userName: userNameToSearch, house: house)
                    statusMessage = result
                    
                    if result.contains("successfully") {
                        isSuccess = true
                        // Close after a short delay so they can see the success message
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } else {
                        isSuccess = false
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(userNameToSearch.isEmpty)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Member")
            .toolbar {
                Button("Cancel") { dismiss() }
            }
        }
    }
    
}
