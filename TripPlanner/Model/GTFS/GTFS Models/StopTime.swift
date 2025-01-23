//
//  StopTime.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class StopTime: Identifiable, Equatable, Hashable, CSVDecodable, Codable, CustomStringConvertible {
    var id: Int { order }
    var order: Int
    var stopID: String
    var tripID: String
    var arrivalTime: String
    var departureTime: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(stopID)
        hasher.combine(tripID)
        hasher.combine(order)
        hasher.combine(arrivalTime)
        hasher.combine(departureTime)
    }
    
    static func == (_ lhs: StopTime, _ rhs: StopTime) -> Bool {
        return lhs.stopID == rhs.stopID &&
               lhs.tripID == rhs.tripID &&
               lhs.order == rhs.order &&
               lhs.arrivalTime == rhs.arrivalTime &&
               lhs.departureTime == rhs.departureTime
    }
    
    enum CodingKeys: CodingKey {
        case order
        case stopID
        case tripID
        case arrivalTime
        case departureTime
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.order, forKey: .order)
        try container.encode(self.stopID, forKey: .stopID)
        try container.encode(self.tripID, forKey: .tripID)
        try container.encode(self.arrivalTime, forKey: .arrivalTime)
        try container.encode(self.departureTime, forKey: .departureTime)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.order = try container.decode(Int.self, forKey: .order)
        self.stopID = try container.decode(String.self, forKey: .stopID)
        self.tripID = try container.decode(String.self, forKey: .tripID)
        self.arrivalTime = try container.decode(String.self, forKey: .arrivalTime)
        self.departureTime = try container.decode(String.self, forKey: .departureTime)
    }
    
    init(order: Int, stopID: String, tripID: String, arrivalTime: String, departureTime: String) {
        self.order = order
        self.stopID = stopID
        self.tripID = tripID
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
    }
    
    init(fromCSV CSV: [String]) {
        self.order = Int(CSV[3])!
        self.stopID = CSV[2]
        self.tripID = CSV[4]
        self.arrivalTime = CSV[0]
        self.departureTime = CSV[1]
    }
    
    var description: String {
        "stopID: \(stopID), tripID: \(tripID), order: \(order), arrivalTime: \(arrivalTime), departureTime: \(departureTime)"
    }
}
