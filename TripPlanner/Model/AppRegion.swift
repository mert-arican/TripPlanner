//
//  AppRegion.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import Foundation

enum AppRegion: String {
    case singapore
    
    var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("ComputedData\(self.rawValue).json")
    }
    
    static var allServiceIDs: [GTFSCalendar]!
    
    static var serviceCondition: ((String)->Bool) {
        var allAvailableServices = [String]()
        for serviceID in Self.allServiceIDs {
            if serviceID.serviceAvailable(at: dayOfTheWeek)  {
                allAvailableServices.append(serviceID.serviceID)
            }
        }
        return { tripID in allAvailableServices.contains(tripID) }
    }
}
