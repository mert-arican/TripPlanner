//
//  Transfer.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

@Model
final class Transfer: Identifiable, CSVDecodable, CustomStringConvertible {
    var sourceStopID: String
    var destinationStopID: String
    var transferType: Int
    
    init(sourceStopID: String, destinationStopID: String, transferType: Int) {
        self.sourceStopID = sourceStopID
        self.destinationStopID = destinationStopID
        self.transferType = transferType
    }
    
    init(fromCSV CSV: [String]) {
        self.sourceStopID = CSV[0]
        self.destinationStopID = CSV[1]
        self.transferType = Int(CSV[2])!
    }
    
    var description: String {
        "sourceStopID: \(sourceStopID), destinationStopID: \(destinationStopID), transferType: \(transferType)"
    }
}
