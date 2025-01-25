//
//  GTFSCalendar+ServiceAvailable.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation

extension GTFSCalendar {
    func serviceAvailable(at day: Int) -> Bool {
        dayArray[day]!
    }
    
    var dayArray: [Int : Bool] {
        [
            1 : self.monday,
            2 : self.tuesday,
            3 : self.wednesday,
            4 : self.thursday,
            5 : self.friday,
            6 : self.saturday,
            7 : self.sunday
        ]
    }
}
