//
//  JourneyComponent.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation

enum JourneyComponent: Identifiable {
    case trip(Trip, start: Stop, destination: Stop)
    case walking(distance: Int, start: Stop, destination: Stop)
    
    var id: String {
        switch self {
        case .trip(let trip, let start, let destination):
            return trip.id+start.id+destination.id
        case .walking(let distance, let start, let destination):
            return String(distance)+start.id+destination.id
        }
    }
}
