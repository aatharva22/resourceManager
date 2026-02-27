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
                    NavigationLink(resource.name, value: resource)
                }
            
                .navigationDestination(for: Resource.self) { resource in
                    ResourceDetailView(resource: resource)
                }
                .navigationTitle("Resources")
                .toolbar{
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        .environment(bookingManager) // given to the environment, so can be accesed from all the views
        .onAppear() {
            addTestData()
        }
        }
    
    func addTestData() {
        let k = Resource(name: "kitchen")
        let b = Resource(name: "bathroom")
        modelContext.insert(k)
        modelContext.insert(b)
    }
    
        
    }


   

#Preview {
    ResourceListView()
        .modelContainer(for: Resource.self, inMemory: true)
}

