//
//  TripPlanner.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation
import CoreLocation
import SwiftData

struct JourneyPlanner {
    let stopTimes: [String : [String: StopTime]]
    let stopsByTripID: [String : [Stop]]
    let tripsByStopID: [String : [Trip]]
    
    let transferableStops: [String : [Stop]] // Maps stop id with the list of transferable stops
    let stopTimeOrder: [String : [String : Int]] // Maps trip id with another dictionary which maps stop id with order of the stop within that trip
    let tree: KDTree<EquirectangularStop>
    
    init(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<GTFSCalendar>()
        AppRegion.allServiceIDs = try! modelContext.fetch(fetchDescriptor)
        let fileURL = appRegion.fileURL
        GTFSManager.createDatabaseIfNotExist(modelContext: modelContext)
        let data = try! Data(contentsOf: fileURL)
        // Load the data from the file
        // Decode the data and assign it to the properties
        let loadedData = try! JSONDecoder().decode(ComputedData.self, from: data)
        self.stopTimes = loadedData.stopTimes
        self.stopsByTripID = loadedData.stopsByTripID
        var tmp = loadedData.tripsByStopID
        let condition = AppRegion.serviceCondition
        for (key, value) in tmp {
            tmp[key] = value.filter {
                condition($0.serviceID)
            }
        }
        self.tripsByStopID = tmp
        self.transferableStops = loadedData.transferableStops
        self.stopTimeOrder = loadedData.stopTimeOrder
        self.tree = loadedData.tree
    }
    
    static var shared: JourneyPlanner!
    
    func findJourneys(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> [[JourneyComponent]]? {
        let theSource = tree.nearest(to: .init(stop: .empty, point: source.point))!
        let sources = transferableStops[theSource.stop.id]!
        let theDestination = tree.nearest(to: .init(stop: .empty, point: destination.point))!
        let destinations = Set(transferableStops[theDestination.stop.id]!)
        return raptorizedBFS(from: sources, to: destinations)
    }
    
    // Influenced by RAPTOR algorithm. But RAPTOR isn't mainly designed for building the complete trip.
    // Also it doesn't support multiple source and destinations.
    // This function is a mix of RAPTOR and BFS.
    // It finds maximum of four distincs trips between given sources and destinations.
    private func raptorizedBFS(from sources: [Stop], to destinations: Set<Stop>, _ dontPickTheseTrips: Set<Trip?>=[]) -> [[JourneyComponent]]? {
        var dontPickTheseTrips = dontPickTheseTrips
        let numberOfTransfers = 3
        
        var rounds = [[[JourneyComponent]]]()
        rounds.reserveCapacity(numberOfTransfers + 1)
        rounds = Array(repeating: [], count: numberOfTransfers + 1)
        rounds[0] = sources.map { [JourneyComponent.stop($0)] }
        
        var visited = Set<String>()
        var successfulTrips = [[JourneyComponent]]()
        var goalReached = false
        
        for k in 0..<numberOfTransfers {
            let currentRound = rounds[k]
            rounds[k + 1] = []
            
            for path in currentRound {
                if path.contains(where: { $0.type == 2 && dontPickTheseTrips.contains($0.trip) }) { continue }
                let lastStop = path.last(where: { $0.type == 1 })!.stop
                let connectedTrips = Set((tripsByStopID[lastStop.id] ?? [])
                    .filter { trip in !(dontPickTheseTrips).contains(where: { $0?.routeID == trip.routeID }) })
                
                for trip in connectedTrips
                {
                    let downstreamStops = stopsByTripID[trip.id]!
                        .suffix(from: stopTimeOrder[trip.id]![lastStop.id]!+1)
                    
                    for stop in downstreamStops where !visited.contains(stop.id) {
                        let newPath = path + [.trip(trip), .stop(stop)]
                        rounds[k + 1].append(newPath)
                        visited.insert(stop.id)
                        
                        if destinations.contains(stop) {
                            successfulTrips.append(newPath)
                            dontPickTheseTrips.insert(newPath.first(where: { $0.type == 2 && !dontPickTheseTrips.contains($0.trip)})?.trip)
                            goalReached = true
                            if dontPickTheseTrips.count == 4 { return successfulTrips }
                            else { break }
                        }
                        
                        let walkableStops = transferableStops[stop.id]!.filter { stop in
                            !newPath.contains(where: { $0 == stop })
                        }
                        
                        for walkableStop in walkableStops where !visited.contains(walkableStop.id) {
                            let distance = Int(sqrt(stop.point.squaredDistance(to: walkableStop.point)))
                            let walkByPath = newPath + [.walking(distance: distance), .stop(walkableStop)]
                            rounds[k + 1].append(walkByPath)
                            visited.insert(walkableStop.id)
                            
                            if destinations.contains(walkableStop) {
                                successfulTrips.append(walkByPath)
                                goalReached = true
                                dontPickTheseTrips.insert(walkByPath.first(where: { $0.type == 2 && !dontPickTheseTrips.contains($0.trip)})?.trip)
                                if dontPickTheseTrips.count == 4 { return successfulTrips }
                                else { break }
                            }
                        }
                        
                        if goalReached {
                            return successfulTrips + (raptorizedBFS(from: sources, to: destinations, dontPickTheseTrips) ?? [])
                        }
                    }
                }
            }
        }
        return successfulTrips.count == 0 ? nil : successfulTrips
    }
}
