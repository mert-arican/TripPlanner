//
//  CLLocationCoordinate2D+Projection.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    var point: CGPoint {
        projection.project(latitude: latitude, longitude: longitude)
    }
    
    var coordinateText: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
}
