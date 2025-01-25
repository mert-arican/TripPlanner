//
//  Stop+Project.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation
import CoreLocation

extension Stop {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    var point: CGPoint {
        projection.project(latitude: latitude, longitude: longitude)
    }
    
    static var empty: Stop {
        .init(id: "", code: "", latitude: 0.0, longitude: 0.0, name: "", url: "", wheelchairBoarding: false)
    }
}
