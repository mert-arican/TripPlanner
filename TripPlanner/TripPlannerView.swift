//
//  TripPlannerView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 24.01.2025.
//

import SwiftUI
import SwiftData
import MapKit

struct TripPlannerView: View {
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
        let tree = KDTree(values: shapes.map { KDTreeOrder(point: $0.point, order: 0) })
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
            .edgesIgnoringSafeArea(.all)
        }
    }
}
