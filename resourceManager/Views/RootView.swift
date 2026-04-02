
import SwiftData
import SwiftUI


struct RootView: View {
    @Environment(\.modelContext) private var modelContext // Grabs the context injected by App
    @State private var isLoggedIn: Bool = false
    @State private var bookingManager: BookingManager? // Optional at first

    var body: some View {
        Group {
            // Check if manager is ready
            if let manager = bookingManager {
                if isLoggedIn {
                    TabView{
//                        NavigationStack {
//                            ResourceListView()
//                        }
//                        .tabItem {
//                            Label("Resources", systemImage: "house")
//                        }
                        
                        NavigationStack {
                            HouseListView()
                        }
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        NavigationStack {
                            BookingForUser(user:manager.currentUser!)
                        }
                        .tabItem {
                            Label("My bookings", systemImage: "book.fill")
                        }
                        
                        NavigationStack{
                            ProfileView(isLoggedIn: $isLoggedIn)
                        }
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle")
                        }
                    } .environment(manager) // passing the manager
                } else {
                    NavigationStack {
                        LoginView(bookingManager: manager, isLoggedIn: $isLoggedIn)
                    }
                }
            } else {
                // Temporary loading state while manager initializes
                ProgressView()
            }
        }
        // This is the "Magic" moment: Initialize manager once the View is in the UI tree
        .onAppear {
            if bookingManager == nil {
                bookingManager = BookingManager(modelContext: modelContext)
            }
        }
    }
}
