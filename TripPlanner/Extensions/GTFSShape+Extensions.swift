//
//  GTFSShape+Project.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation
import CoreLocation

extension GTFSShape {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    var point: CGPoint { coordinate.point }
}
