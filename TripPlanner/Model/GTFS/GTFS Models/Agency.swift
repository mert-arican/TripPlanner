//
//  Agency.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Agency: Identifiable, CSVDecodable, CustomStringConvertible {
    var id: String
    var name: String
    var url: String
    var timeZone: String
    
    init(id: String, name: String, url: String, timeZone: String) {
        self.id = id
        self.name = name
        self.url = url
        self.timeZone = timeZone
    }
    
    init(fromCSV CSV: [String]) {
        self.id = CSV[0]
        self.name = CSV[1]
        self.url = CSV[2]
        self.timeZone = CSV[3]
    }
    
    var description: String {
        "id: \(id), name: \(name), url: \(url), timeZone: \(timeZone)"
    }
}
