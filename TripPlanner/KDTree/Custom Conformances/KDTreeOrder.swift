//
//  Int+KDTreePoint.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 24.01.2025.
//

import Foundation

struct KDTreeOrder: KDTreePoint {
    let point: CGPoint
    let order: Int
    
    static var dimensions: Int = 2
    
    func kdDimension(_ dimension: Int) -> Double {
        point.kdDimension(dimension)
    }
    
    func squaredDistance(to otherPoint: KDTreeOrder) -> Double {
        point.squaredDistance(to: otherPoint.point)
    }
}
