import SwiftUI
struct AddHouseView: View {
    @Environment(BookingManager.self) private var manager
    @Environment(\.dismiss) private var dismiss
    
    @State private var houseName: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("House Details")) {
                    TextField("House Name (e.g., Summer Cabin)", text: $houseName)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red).font(.caption)
                }
            }
            .navigationTitle("New House")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveHouse()
                    }
                    .disabled(houseName.isEmpty)
                }
            }
        }
    }

    func saveHouse() {
        do {
            try manager.createHouse(name: houseName)
            dismiss() // Close the sheet on success
        } catch {
            errorMessage = "Could not create house. Try a different name."
        }
    }
}

#Preview {
    AddHouseView()
}
