import SwiftUI
import _SwiftData_SwiftUI
struct ResourceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Resource.name) private var resources: [Resource]
    
    // We initialize the manager here
    @State private var bookingManager: BookingManager?

    var body: some View {
        NavigationStack {
            List(resources) { resource in
                NavigationLink(value: resource) {
                    HStack {
                        Image(systemName: resource.iconName)
                            .foregroundColor(.blue)
                        Text(resource.name)
                        Spacer()
                        // A quick preview of the limit
                        Text("\(resource.timeLimit.minutes)m limit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Shared Spaces")
            .onAppear {
                // Set up the manager when the view appears
                bookingManager = BookingManager(modelContext: modelContext)
            }
            .toolbar {
                Button("Add Sample") {
                    addTestData()
                }
            }
            .navigationDestination(for: Resource.self) { resource in
                // We'll build this screen next!
                Text("Booking for \(resource.name)")
            }
        }
    }

    func addTestData() {
        let k = Resource(name: "Main Kitchen", iconName: "kitchen", type: .kitchen)
        let b = Resource(name: "Master Bath", iconName: "bathroom", type: .bathroom)
        modelContext.insert(k)
        modelContext.insert(b)
    }
}
