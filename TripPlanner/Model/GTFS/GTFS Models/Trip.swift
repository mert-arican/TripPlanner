//
//  Trip.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Trip: Identifiable, Equatable, Hashable, CSVDecodable, Codable, CustomStringConvertible {
    var id: String
    var routeID: String
    var shapeID: String
    var serviceID: String
    var directionID: Int
    var tripHeadsign: String
    var wheelchairAccessible: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(routeID)
    }
    
    static func ==(_ lhs: Trip, _ rhs: Trip) -> Bool {
        lhs.id == rhs.id && lhs.routeID == rhs.routeID
    }
    
    // Default initializer
    init(id: String, routeID: String, shapeID: String, serviceID: String, directionID: Int, tripHeadsign: String, wheelchairAccessible: Bool) {
        self.id = id
        self.routeID = routeID
        self.shapeID = shapeID
        self.serviceID = serviceID
        self.directionID = directionID
        self.tripHeadsign = tripHeadsign
        self.wheelchairAccessible = wheelchairAccessible
    }
    
    // CSV initializer
    init(fromCSV CSV: [String]) {
        self.id = CSV[5]
        self.routeID = CSV[1]
        self.shapeID = CSV[3]
        self.serviceID = CSV[2]
        self.directionID = Int(CSV[0])!
        self.tripHeadsign = CSV[4]
        self.wheelchairAccessible = CSV[6] == "1"
    }

    // Description for debug printing
    var description: String {
        "routeID: \(routeID), id: \(id)"
    }

    // MARK: - Codable Conformance

    // Custom implementation of the encode(to:) method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(routeID, forKey: .routeID)
        try container.encode(shapeID, forKey: .shapeID)
        try container.encode(serviceID, forKey: .serviceID)
        try container.encode(directionID, forKey: .directionID)
        try container.encode(tripHeadsign, forKey: .tripHeadsign)
        try container.encode(wheelchairAccessible, forKey: .wheelchairAccessible)
    }

    // Custom implementation of the init(from:) method
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        routeID = try container.decode(String.self, forKey: .routeID)
        shapeID = try container.decode(String.self, forKey: .shapeID)
        serviceID = try container.decode(String.self, forKey: .serviceID)
        directionID = try container.decode(Int.self, forKey: .directionID)
        tripHeadsign = try container.decode(String.self, forKey: .tripHeadsign)
        wheelchairAccessible = try container.decode(Bool.self, forKey: .wheelchairAccessible)
    }

    // CodingKeys to map properties to JSON keys
    enum CodingKeys: String, CodingKey {
        case id
        case routeID
        case shapeID
        case serviceID
        case directionID
        case tripHeadsign
        case wheelchairAccessible
    }
}
