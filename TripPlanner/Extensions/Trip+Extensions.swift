//
//  Trip+IsRailway.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation

extension Trip {
    var isRailway: Bool {
        railRoutes.contains(self.routeID)
    }
}
