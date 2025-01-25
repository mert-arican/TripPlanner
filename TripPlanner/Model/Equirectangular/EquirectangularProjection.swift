//
//  EquirectangularProjection.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation

struct EquirectangularProjection {
    let centerLatitude: Double =  1.3521
    let centerLongitude: Double = 103.8198
    let scale: Double = 1.0 // Scale factor for your map size (in meters or pixels)
    
    func project(latitude: Double, longitude: Double) -> CGPoint {
        // Radius of the Earth in meters (approximate)
        let R = 6371000.0 // Approximate radius in meters
        
        // Convert latitude and longitude to radians
        let latRad = latitude * .pi / 180
        let lonRad = longitude * .pi / 180
        let centerLatRad = centerLatitude * .pi / 180
        let centerLonRad = centerLongitude * .pi / 180
        
        // Calculate the equirectangular projection (X, Y)
        let x = R * (lonRad - centerLonRad) * scale
        let y = R * (latRad - centerLatRad) * scale
        return .init(x: x, y: y)
    }
}
