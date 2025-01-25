//
//  Constantstinopolis.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

let appRegion = AppRegion.singapore

let dayOfTheWeek: Int = {
    let dayOfWeek = Calendar.current.component(.weekday, from: Date())
    let mapping = [1:7, 2:1, 3:2, 4:3, 5:4, 6:5, 7:6]
    return mapping[dayOfWeek]!
}()

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
