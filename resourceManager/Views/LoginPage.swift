//
//  LoginPage.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 2/28/26.
//

import Foundation
import SwiftData
import SwiftUI

struct LoginView: View {
    var bookingManager : BookingManager
    @Binding var isLoggedIn : Bool
    @State private var loginResult : String = ""
    @State private var userName: String = ""
    @State private var password: String = "" // Added for standard practice
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Welcome Back")
                    .font(.largeTitle)
                    .bold()
                
                Text(loginResult).font(.subheadline).foregroundColor(.red)
                
                VStack(alignment: .leading) {
                    Text("Username")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter your name", text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                
                VStack(alignment: .leading) {
                    Text("Password")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                
                    Button(action: login) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userName.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(userName.isEmpty)
                NavigationLink(destination: SignupPage(bookingManager: bookingManager, isLoggedIn: $isLoggedIn)) {
                    // Style the label of the link directly
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } .navigationTitle("LoginIn")
                    .navigationBarTitleDisplayMode(.inline)
                
            }
        
            .padding()
        
    }

    func login() {
        // Here you would check your SwiftData 'User' models
        // to see if this user exists, then set your logged-in state.
        
        if bookingManager.checkLogin(userName: userName, password: password) {
            isLoggedIn = true
        }
        else {
            loginResult = "Invalid Credentials, please try again"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                loginResult = ""
            }
            
        }
    }
}

#Preview {
    // 1. Create an in-memory container for the preview
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, House.self, Resource.self, Booking.self, configurations: config)
    
    // 2. Initialize the manager with the preview context
    let manager = BookingManager(modelContext: container.mainContext)

    // 3. Return the view with a constant binding and the manager
    LoginView(bookingManager: manager, isLoggedIn: .constant(false))
        .modelContainer(container)
}
