//
//  ContentView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import SwiftUI
import SwiftData
import MapKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var startingPoint: CLLocationCoordinate2D?
    @State private var destinationPoint: CLLocationCoordinate2D?
    
    private var tripPlanner: TripPlanner {
        TripPlanner.shared
    }
    
    private let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), // Singapore's coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.42, longitudeDelta: 0.42) // Zoom level
    )
    
    @State private var foundTrips: [[RouteComponent]]?
    @State private var selectedTripIndex: Int?
    
    // @State private var pendingTripRequest: Bool = false
    
    private func getPoints(of trip: Trip, between source: Stop, and destination: Stop) -> [MKMapPoint] {
        let shapeID = trip.shapeID
        let shapeFetch = FetchDescriptor<GTFSShape>(predicate: #Predicate {
            $0.id == shapeID
        }, sortBy: [SortDescriptor(\GTFSShape.order)])
        let shapes = try! modelContext.fetch(shapeFetch)
        let tree = KDTree(values: shapes.map { GTFSShape.KDShape(point: $0.point, order: 0) })
        let source = tree.nearest(to: .init(point: source.point, order: 0))!.order - 1
        let destination = tree.nearest(to: .init(point: destination.point, order: 0))!.order - 1
        if source > destination {
            return shapes[destination...source].map { MKMapPoint($0.coordinate) }
        }
        return shapes[source...destination].map { MKMapPoint($0.coordinate) }
    }
    
    private func highlightTrip(_ trip: [[RouteComponent]]) {
        func mapTripsWithStops(components: [RouteComponent]) -> [(trip: RouteComponent, beforeStop: RouteComponent, afterStop: RouteComponent)] {
            guard components.count >= 3 else { return [] }
            
            var results: [(RouteComponent, RouteComponent, RouteComponent)] = []
            // Generics for enums???? !!!
            for i in 1..<components.count - 1 {
                if case let .trip(tripID) = components[i],
                   case let .stop(beforeStopID) = components[i - 1],
                   case let .stop(afterStopID) = components[i + 1] {
                    results.append((.trip(tripID), .stop(beforeStopID), .stop(afterStopID)))
                }
            }
            return results
        }
        // Filter through the selected trip to:
            // Get all trips by start and destination
            // Get all walks by start and destination
            //
    }
    
    var body: some View {
        ZStack {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    
                }
                .onTapGesture { touchPosition in
                    if let touchPoint = proxy.convert(touchPosition, from: .local) {
                        if startingPoint == nil {
                            self.startingPoint = touchPoint
                        }
                        else if destinationPoint == nil {
                            self.destinationPoint = touchPoint
                        }
                        if let start = startingPoint, let destination = destinationPoint {
                            self.foundTrips = tripPlanner.findTrips(from: start, to: destination)
                            self.selectedTripIndex = 0
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            GTFSManager.createDatabaseIfNotExist(modelContext: modelContext)
            TripPlanner.shared = TripPlanner(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}

fileprivate extension TripPlanner {
    init(modelContext: ModelContext) {
        let fileManager = FileManager.default
        let fileURL = Self.getFileURL()
        
        if fileManager.fileExists(atPath: fileURL.path), let data = try? Data(contentsOf: fileURL) {
            // Load the data from the file
            // Decode the data and assign it to the properties
            let loadedData = try! JSONDecoder().decode(ComputedData.self, from: data)
            self.stopTimes = loadedData.stopTimes
            self.stopsByTripID = loadedData.stopsByTripID
            var tmp = loadedData.tripsByStopID
            for (key, value) in tmp {
                tmp[key] = value.filter { $0.serviceID == "SUN" || $0.serviceID == "FULLW" }
            }
            self.tripsByStopID = tmp
            self.transferableStops = loadedData.transferableStops
            self.stopTimeOrder = loadedData.stopTimeOrder
            self.tree = loadedData.tree
        }
        else {
            // If the file doesn't exist, fetch and compute the data
            let tripFetchRequest = FetchDescriptor<Trip>()
            let stopTimeFetchRequest = FetchDescriptor<StopTime>()
            let stopFetchRequest = FetchDescriptor<Stop>()
            
            let allTrips = try! modelContext.fetch(tripFetchRequest)
            let allStops = try! modelContext.fetch(stopFetchRequest)
            let allStopTimes = try! modelContext.fetch(stopTimeFetchRequest)
            
            let tripLookup = Dictionary(uniqueKeysWithValues: allTrips.map { ($0.id, $0) })
            let stopLookup = Dictionary(uniqueKeysWithValues: allStops.map { ($0.id, $0) })
            
            self.stopTimes = Dictionary(grouping: allStopTimes, by: { $0.tripID })
            
            self.stopsByTripID = Dictionary(grouping: allStopTimes, by: { $0.tripID })
                .mapValues { stopTimes in
                    // Sort the stopTimes by order and map to the corresponding stops
                    stopTimes
                        .sorted(by: { $0.order < $1.order })
                        .compactMap { stopLookup[$0.stopID] }
                }
            
            self.tripsByStopID = Dictionary(grouping: allStopTimes, by: { $0.stopID })
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
            
            self.stopTimeOrder = stopOrderLookup
            
            let equirectangularStops = allStops.map { EquirectangularStop(stop: $0, point: $0.point) }
            
            let tree = KDTree(values: equirectangularStops)
            
            self.transferableStops = Dictionary(uniqueKeysWithValues: equirectangularStops.map { ($0.stop.id, $0) })
                .mapValues { stop in
                    // nn: neares neighbors
                    var nn = tree.allPoints(within: 600.0, of: stop)
                    if nn.count < 10 { nn = tree.nearestK(10, to: stop) }
                    return nn.map { $0.stop }
                }
            
            self.tree = tree
            
            // Save the computed data to the file
            self.saveData(to: fileURL)
        }
    }
    
    // Method to get the file URL
    static func getFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("ComputedData.json")
    }
    
    // Method to save the data to the file
    func saveData(to url: URL) {
        let dataToSave = ComputedData(stopTimes: self.stopTimes, stopsByTripID: self.stopsByTripID, tripsByStopID: self.tripsByStopID, transferableStops: self.transferableStops, stopTimeOrder: self.stopTimeOrder, tree: self.tree)
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(dataToSave) {
            try? encodedData.write(to: url)
        }
    }
}

extension GTFSShape {
    fileprivate struct KDShape: KDTreePoint {
        let point: CGPoint
        let order: Int
        
        static var dimensions: Int = 2
        
        func kdDimension(_ dimension: Int) -> Double {
            point.kdDimension(dimension)
        }
        
        func squaredDistance(to otherPoint: GTFSShape.KDShape) -> Double {
            point.squaredDistance(to: otherPoint.point)
        }
    }
    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    
    var point: CGPoint { coordinate.point }
}
