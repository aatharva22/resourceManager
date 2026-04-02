//
//  BookingView.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/13/26.
//

import Foundation
import SwiftUI
struct BookingView: View {
    
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(1800)
    @State private var error: String = ""
    @Environment(BookingManager.self) private var manager
    
    
    var resource : Resource
    @Binding var isPresented : Bool
    
    var body: some View {
        Text("Add Booking")
        Group {
            VStack{
                Text(error)
                Form {
                    Section(header: Text("Schedule")) {
                        // Start Date & Time
                        DatePicker("Start",
                                   selection: $startTime,
                                   in: Date()..., // Prevents picking dates in the past
                                   displayedComponents: [.date, .hourAndMinute])
                        
                        // End Date & Time
                        DatePicker("End",
                                   selection: $endTime,
                                   in: startTime..., // Prevents picking an end date before start date
                                   displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Button(action: addBooking) {
                    Text("Add Booking")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Button(action:{
                    isPresented = false
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            }
            
        }
    }
    
    func addBooking() {
        do {
            try manager.addBooking(resource, startTime, endTime, user: manager.currentUser!)
            isPresented = false
        } catch BookingManager.BookingError.invalidTime {
//            print("Error: The start time must be before the end time.")
            error = "Error: The start time must be before the end time."
            // Show an alert to the user here
            
        } catch BookingManager.BookingError.overlap {
//            print("Error: This slot is already taken or you have another booking.")
            error = "Error: This slot is already taken or you have another booking."
        } catch BookingManager.BookingError.timeExceeded {
//            print("Error: This booking exceeds the allowed time limit for this resource.")
            error = "Error: This booking exceeds the allowed time limit for this resource."
            
        } catch {
            // Fallback for any other unexpected errors
            print("An unexpected error occurred: \(error.localizedDescription)")
        }
        
        
            
        }
}
 
