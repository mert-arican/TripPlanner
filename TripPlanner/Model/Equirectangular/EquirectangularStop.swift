//
//  EquirectangularStop.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation

// Aggregate struct of Stop's and their projected point in cartesian coordinate system
// Equirectangular is name of the projection used
struct EquirectangularStop: Equatable, KDTreePoint, Codable {
    let stop: Stop
    let point: CGPoint
    static var dimensions: Int = 2
    
    func kdDimension(_ dimension: Int) -> Double {
        self.point.kdDimension(dimension)
    }
    
    func squaredDistance(to otherPoint: EquirectangularStop) -> Double {
        self.point.squaredDistance(to: otherPoint.point)
    }
    
    static func ==(_ lhs: EquirectangularStop, _ rhs: EquirectangularStop) -> Bool {
        lhs.point == rhs.point
    }
}
