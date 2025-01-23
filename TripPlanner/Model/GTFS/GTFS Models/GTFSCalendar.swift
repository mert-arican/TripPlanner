//
//  GTFSCalendar.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class GTFSCalendar: Identifiable, CSVDecodable, CustomStringConvertible {
    var serviceID: String
    var monday: Bool
    var tuesday: Bool
    var wednesday: Bool
    var thursday: Bool
    var friday: Bool
    var saturday: Bool
    var sunday: Bool
    
    init(serviceID: String, monday: Bool, tuesday: Bool, wednesday: Bool, thursday: Bool, friday: Bool, saturday: Bool, sunday: Bool) {
        self.serviceID = serviceID
        self.monday = monday
        self.tuesday = tuesday
        self.wednesday = wednesday
        self.thursday = thursday
        self.friday = friday
        self.saturday = saturday
        self.sunday = sunday
    }
    
    init(fromCSV CSV: [String]) {
        self.serviceID = CSV[0]
        self.monday = CSV[1] == "1"
        self.tuesday = CSV[2] == "1"
        self.wednesday = CSV[3] == "1"
        self.thursday = CSV[4] == "1"
        self.friday = CSV[5] == "1"
        self.saturday = CSV[6] == "1"
        self.sunday = CSV[7] == "1"
    }
    
    var description: String {
        "serviceID: \(serviceID), monday: \(monday), tuesday: \(tuesday), wednesday: \(wednesday), thursday: \(thursday), friday: \(friday), saturday: \(saturday), sunday: \(sunday)"
    }
}
