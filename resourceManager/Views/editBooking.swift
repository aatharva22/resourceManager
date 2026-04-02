//
//  editBooking.swift
//  resourceManager
//
//  Created by Atharva Sonawane on 3/23/26.
//

import Foundation
import SwiftUI

struct EditBooking: View {
    @Environment(BookingManager.self) private var manager
    var booking : Booking
    var body: some View {
        Button(action: deleteBooking) {
            Text("DeleteBooking")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
    
    func deleteBooking() {
        manager.deleteBooking(booking)
    }
}
