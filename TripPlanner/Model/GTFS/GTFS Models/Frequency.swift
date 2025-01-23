//
//  Frequency.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Frequency: Identifiable, CSVDecodable, CustomStringConvertible {
    var tripID: String
    var startTime: String
    var endTime: String
    var headwaySeconds: Int
    
    init(tripID: String, startTime: String, endTime: String, headwaySeconds: Int) {
        self.tripID = tripID
        self.startTime = startTime
        self.endTime = endTime
        self.headwaySeconds = headwaySeconds
    }
    
    init(fromCSV CSV: [String]) {
        self.tripID = CSV[0]
        self.startTime = CSV[1]
        self.endTime = CSV[2]
        self.headwaySeconds = Int(CSV[3])!
    }
    
    var description: String {
        "tripID: \(tripID), startTime: \(startTime), endTime: \(endTime), headwaySeconds: \(headwaySeconds)"
    }
}
