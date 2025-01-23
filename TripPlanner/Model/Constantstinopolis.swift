//
//  Constantstinopolis.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation

let projection = EquirectangularProjection()

// route type == 1
let railRoutes = Set(["SW", "TE", "SE", "PW", "PE", "NS", "NE", "EW", "DT", "CG", "CE", "CC", "BP",])

extension Trip {
    var isRailway: Bool {
        railRoutes.contains(self.routeID)
    }
}

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
