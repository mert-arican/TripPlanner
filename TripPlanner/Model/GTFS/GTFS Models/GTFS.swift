//
//  GTFS.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation

enum GTFS: String, CaseIterable {
    case agency
    case calendar
    case frequencies
    case routes
    case shapes
    case stop_times
    case stops
    case transfer
    case trips
}
