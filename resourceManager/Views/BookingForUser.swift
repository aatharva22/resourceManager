//
//  BookingListView.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/13/26.
//

import Foundation
import SwiftUI


struct BookingForUser: View {
    
    var user : User
    @State private var bookingList: [Booking] = []
    @Environment(BookingManager.self) var manager
    @State var isPresented:Bool = false
    
    var body: some View {
        
        Group{
            List(bookingList) { booking in
                NavigationLink(value: booking){
                    VStack(alignment: .leading){
                        HStack{
                            
                            Text("Resource allocated: \(booking.resource?.name ?? "")").font(.headline)
                        }
                        HStack{
                            Text("House name: \(booking.resource?.houseName?.name ?? "")").font(.headline)
                        }
                        HStack{
                            Text("Start: \(booking.startTime.formatted(date: .omitted, time: .shortened))")
                            Text("End: \(booking.endTime.formatted(date: .omitted, time: .shortened))")
                        }
                    }
                }
                
            }
        
        }
        .navigationDestination(for: Booking.self) { booking in
            //ResourceDetailView(resource: resource)
            //EditBooking( booking: booking)
        }

        .navigationTitle("\(user.name)'s bookings")
            .toolbar{
                Button(action: {
                isPresented = true
                }){
                    Image(systemName: "plus")
                }
//                .sheet(isPresented: $isPresented) {
//                    BookingView(resource: resource, isPresented: $isPresented)
//                }
            }
                
        .onAppear() {
            fetchBookings()
        }
    }
    
    func fetchBookings() {
        bookingList = manager.fetchBookingsForUser(for: user.name)
    }
}

