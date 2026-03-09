//
//  ProfileView.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/2/26.
//

import Foundation
import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(BookingManager.self) private var manager
    @Binding var isLoggedIn: Bool
    
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
            
            Text("Profile")
                .font(.largeTitle)
                .bold()
            
            VStack(alignment: .leading) {
                Text(manager.currentUser?.name ?? "Guest")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Button(action: signOut) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            
        }
    }
    
    func signOut() {
        manager.signOut()
        isLoggedIn = false
    }
}

#Preview {
    @Previewable @State var isLoggedIn = true
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, House.self, Resource.self, Booking.self, configurations: config)
    let manager = BookingManager(modelContext: container.mainContext)
    manager.currentUser = .init(name: "Preview User", password: "A")

    return ProfileView(isLoggedIn: $isLoggedIn)
        .environment(manager)
}

