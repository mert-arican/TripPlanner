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
}
