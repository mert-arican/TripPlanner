//
//  GTFS Manager.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import Foundation
import SwiftData

/*
 Handles creating the GTFS database if it doesn't exists. Exposes least info about the
 whole procedure as possible. Nothing except this module should deal with database creation.
 */

struct GTFSManager {
    static func createDatabaseIfNotExist(modelContext: ModelContext) {
        for gtfsComponent in GTFS.allCases {
            if !gtfsComponent.isTableExistsForComponent(modelContext: modelContext) {
                if let csvContent = readCSV(filename: gtfsComponent.rawValue, ofType: "txt") {
                    csvContent.forEach {
                        modelContext.insert(gtfsComponent.initFromCSV($0))
                    }
                    try! modelContext.save()
                }
            }
        }
    }
    
    // MARK: TODO: Save right after the creation of database.
    // Use Constantstinopolis for name of the directory. // Maybe enum with rawValue String
    // static func save
}

fileprivate extension GTFS {
    private func _isTableExistsForComponent<T: PersistentModel>(type: T.Type, modelContext: ModelContext) -> Bool {
        var fetchRequest = FetchDescriptor<T>()
        fetchRequest.fetchLimit = 1
        return (try? modelContext.fetch(fetchRequest).isEmpty == false) ?? false
    }
    
    func isTableExistsForComponent(modelContext: ModelContext) -> Bool {
        switch self {
        case .agency:
            _isTableExistsForComponent(type: Agency.self, modelContext: modelContext)
        case .calendar:
            _isTableExistsForComponent(type: GTFSCalendar.self, modelContext: modelContext)
        case .frequencies:
            _isTableExistsForComponent(type: Frequency.self, modelContext: modelContext)
        case .routes:
            _isTableExistsForComponent(type: Route.self, modelContext: modelContext)
        case .shapes:
            _isTableExistsForComponent(type: GTFSShape.self, modelContext: modelContext)
        case .stop_times:
            _isTableExistsForComponent(type: StopTime.self, modelContext: modelContext)
        case .stops:
            _isTableExistsForComponent(type: Stop.self, modelContext: modelContext)
        case .transfer:
            _isTableExistsForComponent(type: Transfer.self, modelContext: modelContext)
        case .trips:
            _isTableExistsForComponent(type: Trip.self, modelContext: modelContext)
        }
    }
    
    func initFromCSV(_ csv: [String]) -> any PersistentModel & CSVDecodable {
        switch self {
        case .agency:
            Agency(fromCSV: csv)
        case .calendar:
            GTFSCalendar(fromCSV: csv)
        case .frequencies:
            Frequency(fromCSV: csv)
        case .routes:
            Route(fromCSV: csv)
        case .shapes:
            GTFSShape(fromCSV: csv)
        case .stop_times:
            StopTime(fromCSV: csv)
        case .stops:
            Stop(fromCSV: csv)
        case .transfer:
            Transfer(fromCSV: csv)
        case .trips:
            Trip(fromCSV: csv)
        }
    }
}
