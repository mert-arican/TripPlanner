//
//  ComputedData.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation

struct ComputedData: Codable {
    let stopTimes: [String : [String: StopTime]]
    let stopsByTripID: [String : [Stop]]
    let tripsByStopID: [String : [Trip]]
    let transferableStops: [String : [Stop]]
    let stopTimeOrder: [String : [String : Int]]
    let tree: KDTree<EquirectangularStop>
}
