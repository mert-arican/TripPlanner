//
//  JourneyMonogram.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 27.01.2025.
//

import SwiftUI

struct JourneyMonogram: View {
    let trip: Trip
    
    init(for trip: Trip) {
        self.trip = trip
    }
    
    var body: some View {
        HStack {
            Image(systemName: trip.isRailway ? "tram.fill.tunnel" : "bus")
            Text(trip.routeID.uppercased())
        }
        .padding(4.2)
        .overlay(
            RoundedRectangle(cornerRadius: 2.1)
                .stroke(.gray.adjust(by: 42.0), lineWidth: 0.42)
        )
    }
}
