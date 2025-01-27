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
        print("CREATE DATABASE START", Date())
        let savedAppRegion = UserDefaults.standard.string(forKey: "appRegion")
        let shouldClearDatabase = savedAppRegion != appRegion.rawValue
        if shouldClearDatabase {
            for gtfsComponent in GTFS.allCases {
                gtfsComponent.deleteDatabase(modelContext: modelContext)
            }
        }
        
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
        
        // Save preprocessed data to disk
        let fileManager = FileManager.default
        let fileExists = fileManager.fileExists(atPath: appRegion.fileURL.path)
        
        guard !fileExists else { return }
        
        let fetchDescriptor = FetchDescriptor<GTFSCalendar>()
        AppRegion.allServiceIDs = try! modelContext.fetch(fetchDescriptor)
        
        // If the file doesn't exist, fetch and compute the data
        let tripFetchRequest = FetchDescriptor<Trip>()
        let stopTimeFetchRequest = FetchDescriptor<StopTime>()
        let stopFetchRequest = FetchDescriptor<Stop>()
        
        let allTrips = try! modelContext.fetch(tripFetchRequest)
        let allStops = try! modelContext.fetch(stopFetchRequest)
        let allStopTimes = try! modelContext.fetch(stopTimeFetchRequest)
        
        let tripLookup = Dictionary(uniqueKeysWithValues: allTrips.map { ($0.id, $0) })
        let stopLookup = Dictionary(uniqueKeysWithValues: allStops.map { ($0.id, $0) })
        
        let stopTimes = Dictionary(grouping: allStopTimes, by: { $0.tripID })
        
        let stopsByTripID = Dictionary(grouping: allStopTimes, by: { $0.tripID })
            .mapValues { stopTimes in
                // Sort the stopTimes by order and map to the corresponding stops
                stopTimes
                    .sorted(by: { $0.order < $1.order })
                    .compactMap { stopLookup[$0.stopID] }
            }
        
        let tripsByStopID = Dictionary(grouping: allStopTimes, by: { $0.stopID })
            .mapValues { stopTimes in
                Array(Set(stopTimes.compactMap { tripLookup[$0.tripID] }))
            }
        
        // Compute mappings of stopTimeOrder
        var stopOrderLookup: [String: [String: Int]] = [:]
        
        for (tripID, stops) in stopsByTripID {
            for (index, stop) in stops.enumerated() {
                // Ensure the nested dictionary exists for the trip
                if stopOrderLookup[tripID] == nil {
                    stopOrderLookup[tripID] = [:]
                }
                // Assign the order (index + 1 as stop_sequence is 1-based)
                stopOrderLookup[tripID]?[stop.id] = index
            }
        }
        
        let stopTimeOrder = stopOrderLookup
        
        let equirectangularStops = allStops.map { EquirectangularStop(stop: $0, point: $0.point) }
        
        let tree = KDTree(values: equirectangularStops)
        
        let transferableStops = Dictionary(uniqueKeysWithValues: equirectangularStops.map { ($0.stop.id, $0) })
            .mapValues { stop in
                // nn: neares neighbors
                var nn = tree.allPoints(within: 600.0, of: stop)
                if nn.count < 10 { nn = tree.nearestK(10, to: stop) }
                return nn.map { $0.stop }
            }

        // Save preprocessed GTFS
        let processedGTFS = ComputedData(stopTimes: stopTimes, stopsByTripID: stopsByTripID, tripsByStopID: tripsByStopID, transferableStops: transferableStops, stopTimeOrder: stopTimeOrder, tree: tree)
        
        if let encodedData = try? JSONEncoder().encode(processedGTFS) {
            do {
                try encodedData.write(to: appRegion.fileURL)
                UserDefaults.standard.setValue(appRegion.rawValue, forKey: "appRegion")
            }
            catch {
                print("Error writing data to disk.")
            }
        }
        print("CREATE DATABASE END", Date())
    }
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
    
    func deleteDatabase(modelContext: ModelContext) {
        switch self {
        case .agency:
            try! modelContext.delete(model: Agency.self)
        case .calendar:
            try! modelContext.delete(model: GTFSCalendar.self)
        case .frequencies:
            try! modelContext.delete(model: Frequency.self)
        case .routes:
            try! modelContext.delete(model: Route.self)
        case .shapes:
            try! modelContext.delete(model: GTFSShape.self)
        case .stop_times:
            try! modelContext.delete(model: StopTime.self)
        case .transfer:
            try! modelContext.delete(model: Transfer.self)
        case .trips:
            try! modelContext.delete(model: Trip.self)
        case .stops:
            try! modelContext.delete(model: Stop.self)
        }
        try! modelContext.save()
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
