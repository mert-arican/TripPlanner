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
    
    @State private var startingPoint: CLLocationCoordinate2D? // = .init(latitude: 1.332183089428991, longitude: 103.8521371433289)
    @State private var destinationPoint: CLLocationCoordinate2D? // = .init(latitude: 1.337579411339063, longitude: 103.91502156254148)
    
    private var tripPlanner: TripPlanner {
        TripPlanner.shared
    }
    
    private let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), // Singapore's coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.42, longitudeDelta: 0.42) // Zoom level
    )
    
    @State private var foundTrips: [[RouteComponent]]?
    @State private var selectedTripIndex: Int?
        
    private func getPoints(of trip: Trip, between source: Stop, and destination: Stop) -> [MKMapPoint] {
        let shapeID = trip.shapeID
        let shapeFetch = FetchDescriptor<GTFSShape>(predicate: #Predicate {
            $0.id == shapeID
        }, sortBy: [SortDescriptor(\GTFSShape.order)])
        let shapes = try! modelContext.fetch(shapeFetch)
        let tree = KDTree(values: shapes.enumerated().map { KDTreeOrder(point: $1.point, order: $0) })
        let _source = tree.nearest(to: .init(point: source.point, order: 0))!.order
        let destination = tree.nearest(to: .init(point: destination.point, order: 0))!.order
        if _source > destination {
            return shapes[destination..._source].map { MKMapPoint($0.coordinate) }
        }
        return shapes[_source...destination].map { MKMapPoint($0.coordinate) }
    }
    
    func mapTripsWithStops(components: [RouteComponent]) -> [JourneyComponent] {
        guard components.count >= 3 else { return [] } // MARK: TODO !!!
        
        var results: [JourneyComponent] = []
        let firstStop = components[0].stop
        let distance = sqrt(startingPoint!.point.squaredDistance(to: firstStop.point))
        let start = Stop(id: "", code: "", latitude: startingPoint!.latitude, longitude: startingPoint!.longitude, name: "", url: "", wheelchairBoarding: false)
        results.append(.walking(distance: Int(distance), start: start, destination: firstStop))
        
        let ultDestination = Stop(id: "", code: "", latitude: destinationPoint!.latitude, longitude: destinationPoint!.longitude, name: "", url: "", wheelchairBoarding: false)
        
        // Generics for enums???? !!!
        for i in 1..<components.count - 1 {
            if case let .stop(start) = components[i - 1],
               case let .stop(destination) = components[i + 1] {
                if case let .trip(trip) = components[i] {
                    results.append(.trip(trip, start: start, destination: destination))
                }
                else if case let .walking(distance) = components[i] {
                    let dest = (i != components.count - 2) ? destination : ultDestination
                    results.append(.walking(distance: distance, start: start, destination:  dest))
                }
            }
        }
        
        return results
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    if let startingPoint = startingPoint {
                        Marker("Src", coordinate: startingPoint)
                    }
                    if let destinationPoint = destinationPoint {
                        Marker("Dst", coordinate: destinationPoint)
                    }
                    
                    if let tripIndex = selectedTripIndex,
                       let selectedTrip = foundTrips?[tripIndex]
                    {
                        let components = mapTripsWithStops(components: selectedTrip)
                        
                        ForEach(components) { component in
                            switch component {
                            case .trip(let trip, let start, let destination):
                                let points = getPoints(of: trip, between: start, and: destination)
                                MapPolyline(points: points)
                                    .stroke(trip.isRailway ? .purple : .blue, lineWidth: 8.0)
//
//                                ForEach(points.indices, id: \.self) { index in
//                                    if index != 5 {
//                                        Marker("\(index)", coordinate: points[index].coordinate)
//                                    }
//                                }
                                let tripImage = trip.isRailway ?  "tram.fill.tunnel" : "bus"
                                Marker(start.name, systemImage: tripImage, coordinate: start.coordinate)
//                                Marker(destination.name, systemImage: "xmark", coordinate: destination.coordinate)
                                
                            case .walking(_, let start, let destination):
                                let points = [start.coordinate, destination.coordinate].map {
                                    MKMapPoint($0)
                                }
                                MapPolyline(points: points)
                                    .stroke(.yellow, style: StrokeStyle(lineWidth: 8.0, dash: [4.0, 2.0]))
                                Marker(start.name, systemImage: "figure.walk", coordinate: start.coordinate)
//                                Marker(destination.name, systemImage: "figure.walk", coordinate: destination.coordinate)
                            }
                        }
                    }
                }
                .onTapGesture { touchPosition in
                    if let touchPoint = proxy.convert(touchPosition, from: .local) {
                        if startingPoint == nil {
                            self.startingPoint = touchPoint
                            print("Set starting point.")
                        }
                        else if destinationPoint == nil {
                            self.destinationPoint = touchPoint
                            print("Set destination point.")
                        }
                        if let start = startingPoint, let destination = destinationPoint {
                            self.foundTrips = tripPlanner.findTrips(from: start, to: destination)
                            self.selectedTripIndex = 0
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("RouteBolt")
            VStack {
                if let startingPoint = startingPoint {
                    Button {
                        self.startingPoint = nil
                        self.foundTrips = nil
                        self.selectedTripIndex = nil
                    } label: {
                        Text(startingPoint.coordinateText)
                            .padding()
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                }
                if let destinationPoint = destinationPoint {
                    Button {
                        self.destinationPoint = nil
                        self.foundTrips = nil
                        self.selectedTripIndex = nil
                    } label: {
                        Text(destinationPoint.coordinateText)
                            .padding()
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
        }
    }
}


enum JourneyComponent: Identifiable {
    case trip(Trip, start: Stop, destination: Stop)
    case walking(distance: Int, start: Stop, destination: Stop)
    
    var id: String {
        switch self {
        case .trip(let trip, let start, let destination):
            return trip.id+start.id+destination.id
        case .walking(let distance, let start, let destination):
            return String(distance)+start.id+destination.id
        }
    }
    //    case stop(Stop)
}

extension Stop {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var coordinateText: String {
        String(format: "%.6f, %.6f", latitude, longitude)
    }
}
