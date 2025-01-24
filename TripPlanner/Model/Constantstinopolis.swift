//
//  Constantstinopolis.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

enum AppRegion: String {
    case singapore
    
    var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("ComputedData\(self.rawValue).json")
    }
    
    static var serviceCondition: ((String)->Bool) {
        var allAvailableServices = [String]()
        for serviceID in allServiceIDs {
            if serviceID.serviceAvailable(at: dayOfTheWeek)  {
                allAvailableServices.append(serviceID.serviceID)
            }
        }
        return { tripID in allAvailableServices.contains(tripID) }
    }
}

let appRegion = AppRegion.singapore

let dayOfTheWeek: Int = {
    let dayOfWeek = Calendar.current.component(.weekday, from: Date())
    let mapping = [1:7, 2:1, 3:2, 4:3, 5:4, 6:5, 7:6]
    return mapping[dayOfWeek]!
}()

var allServiceIDs: [GTFSCalendar]!

func readCSV(filename: String, ofType type: String) -> [[String]]? {
    if let filepath = Bundle.main.path(forResource: filename, ofType: type) {
        do {
            var result = [[String]]()
            let csvContent = try String(contentsOfFile: filepath)
            
            let rows = csvContent.split(separator: "\n")
            
            for index in 1..<rows.count {
                result.append(rows[index].split(separator: ",", omittingEmptySubsequences: false).map { String($0) })
            }
            return result
        }
        catch {
            print("Error reading the CSV file: \(error.localizedDescription)")
        }
    }
    else {
        print("File not found.")
    }
    return nil
}

let projection = EquirectangularProjection()

// route type == 1
let railRoutes = Set(["SW", "TE", "SE", "PW", "PE", "NS", "NE", "EW", "DT", "CG", "CE", "CC", "BP",])

extension Trip {
    var isRailway: Bool {
        railRoutes.contains(self.routeID)
    }
}

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
