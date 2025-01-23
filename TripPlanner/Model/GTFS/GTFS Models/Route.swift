//
//  Route.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Route: Identifiable, Equatable, Hashable, CSVDecodable, CustomStringConvertible {
    var id: String
    var agencyID: String
    var routeDescription: String
    var longName: String
    var shortName: String
    var routeType: String
    var url: String
    
    init(id: String, agencyID: String, routeDescription: String, routeLongName: String, routeShortName: String, routeType: String, url: String) {
        self.id = id
        self.agencyID = agencyID
        self.routeDescription = routeDescription
        self.longName = routeLongName
        self.shortName = routeShortName
        self.routeType = routeType
        self.url = url
    }
    
    init(fromCSV CSV: [String]) {
        self.id = CSV[2]
        self.agencyID = CSV[0]
        self.routeDescription = CSV[1]
        self.longName = CSV[3]
        self.shortName = CSV[4]
        self.routeType = CSV[5]
        self.url = CSV[6]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(_ lhs: Route, _ rhs: Route) -> Bool {
        lhs.id == rhs.id
    }
    
    var description: String {
        "id: \(id), agencyID: \(agencyID), description: \(routeDescription), longName: \(longName), shortName: \(shortName), routeType: \(routeType), url: \(url)"
    }
}
