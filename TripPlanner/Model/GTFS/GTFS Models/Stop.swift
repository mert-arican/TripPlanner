//
//  Stop.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Stop: Identifiable, Equatable, CSVDecodable, Codable, CustomStringConvertible {
    var id: String
    var url: String
    var code: String
    var name: String
    var latitude: Double
    var longitude: Double
    var wheelchairBoarding: Bool
    
    init(id: String, code: String, latitude: Double, longitude: Double, name: String, url: String, wheelchairBoarding: Bool) {
        self.id = id
        self.code = code
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.url = url
        self.wheelchairBoarding = wheelchairBoarding
    }
    
    static func ==(_ lhs: Stop, _ rhs: Stop) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case code
        case name
        case latitude
        case longitude
        case wheelchairBoarding
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.url = try container.decode(String.self, forKey: .url)
        self.code = try container.decode(String.self, forKey: .code)
        self.name = try container.decode(String.self, forKey: .name)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.wheelchairBoarding = try container.decode(Bool.self, forKey: .wheelchairBoarding)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.url, forKey: .url)
        try container.encode(self.code, forKey: .code)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.latitude, forKey: .latitude)
        try container.encode(self.longitude, forKey: .longitude)
        try container.encode(self.wheelchairBoarding, forKey: .wheelchairBoarding)
    }
    
    init(fromCSV CSV: [String]) {
        self.id = CSV[1]
        self.code = CSV[0]
        self.latitude = Double(CSV[2])!
        self.longitude = Double(CSV[3])!
        self.name = CSV[4]
        self.url = CSV[5]
        self.wheelchairBoarding = CSV[6] == "1"
    }
    
    var description: String {
        "id: \(id), code: \(code), latitude: \(latitude), longitude: \(longitude), name: \(name), url: \(url), wheelchair: \(wheelchairBoarding)"
    }
}

