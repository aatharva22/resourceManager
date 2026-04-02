import SwiftUI
import _SwiftData_SwiftUI
struct ResourceListView: View {
    
    var house: House
    @Environment(\.modelContext) private var modelContext
    //@Query(sort: \Resource.name) private var resources: [Resource]
    @Environment(BookingManager.self) private var manager
    @State private var resources : [Resource] = []
    @State private var isPresented: Bool = false
    @State private var showingAddUser : Bool = false
    

    var body: some View {
        
        
            Group {
                if resources.isEmpty {
                    ContentUnavailableView("No resources Yet",  systemImage: "house", description: Text("Add resources") )
                    
                }
                else {
                    //NavigationStack {
                    List(resources) { resource in
                        NavigationLink(resource.name, value: resource)
                    }
                    
                                        
                    //}
                    
                    
                }
            }.navigationDestination(for: Resource.self) { resource in
                //ResourceDetailView(resource: resource)
                BookingListView( resource: resource)
            }

            .navigationTitle("Resources")
            .toolbar{
                Button(action: {addResource()}) {
                    Image(systemName: "plus")
                }
                if (manager.isCurrentUserAdmin(of: house)) {
                    Button("Add User",systemImage: "person.fill") {
                        showingAddUser = true
                    }.sheet(isPresented: $showingAddUser) {
                        AddUserToHouse(house: house, showingAddUser: $showingAddUser)
                    }
                }
                
            }
        
            .onAppear() {
                    refreshResources()
                    
            
        }.sheet(isPresented: $isPresented) {
            AddResource(house:house, isPresented: $isPresented)
        }.onDisappear() {
            refreshResources()
            
        }
    }
    
    func refreshResources() {
        resources = manager.fetchResourcesForHouse(house:house)
    }
    func addResource() {
        isPresented = true
    }
    
        
    }


   

//#Preview {
//    ResourceListView()
//        .modelContainer(for: Resource.self, inMemory: true)
//}

