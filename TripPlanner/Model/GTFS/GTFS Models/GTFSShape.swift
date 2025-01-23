//
//  GTFSShape.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class GTFSShape: Identifiable, CSVDecodable, CustomStringConvertible {
    var id: String
    var latitude: Double
    var longitude: Double
    var order: Int
    
    init(id: String, latitude: Double, longitude: Double, order: Int) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.order = order
    }
    
    init(fromCSV CSV: [String]) {
        self.id = CSV[0]
        self.latitude = Double(CSV[1])!
        self.longitude = Double(CSV[2])!
        self.order = Int(CSV[3])!
    }
    
    var description: String {
        "id: \(id), latitude: \(latitude), longitude: \(longitude), order: \(order)"
    }
}
