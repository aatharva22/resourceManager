import SwiftUI
import SwiftData
struct HouseListView: View {
    @Environment(BookingManager.self) private var manager
    @State private var houses: [House] = []
    @State private var showingAddHouse = false
    
    

    var body: some View {
        Group {
            if houses.isEmpty {
                ContentUnavailableView("No houses Yet",  systemImage: "house", description: Text("Join a house or create one to get started.") )
                
            }
            else {
                List(houses) { house in
                    NavigationLink(value:house) {
                        HStack{
                            Image(systemName: "house")
                            
                            VStack(alignment: .leading){
                                Text(house.name)
                                    .font(.headline)
                                
                            }
                        }
                    }
                    
                }.navigationDestination(for: House.self) { house in 
                    ResourceListView(house:house)
                }
                .onAppear {
                    refreshHouses()
                    print("refreshHomes called from onAppear")
                }
            }
            
        }.navigationTitle("Houses").navigationBarTitleDisplayMode(.inline).font(.largeTitle).fontWeight(.bold)
            .toolbar {
                Button(action: {
                    showingAddHouse = true
                }) {
                    Image(systemName: "plus")
                }
            }.sheet(isPresented:$showingAddHouse) {
                AddHouseView()
            }.onDisappear() {
                refreshHouses()
                print("refreshHomes called from onDisappear")
            }
        
                    
            
            
    }
    
    func refreshHouses() {
        houses = manager.fetchMyHouses()
    }
}

#Preview {
    // 1. Setup a temporary in-memory container for SwiftData
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, House.self, Resource.self, Booking.self, House_User.self, configurations: config)
    
    // 2. Create the manager using the preview context
    let manager = BookingManager(modelContext: container.mainContext)
    
    // 3. (Optional) Inject mock data so the preview isn't empty
    // let mockHouse = House(name: "Test Cabin")
    // container.mainContext.insert(mockHouse)

    return NavigationStack {
        HouseListView()
    }
    .modelContainer(container)
    .environment(manager) // This is the missing piece!
}
