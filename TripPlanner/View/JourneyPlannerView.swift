//
//  JourneyPlannerView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 24.01.2025.
//

import SwiftUI
import SwiftData
import MapKit

struct JourneyPlannerView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var startingPoint: CLLocationCoordinate2D?
    //    = .init(latitude: 1.380775, longitude: 103.740154)
    //    = .init(latitude: 1.339299, longitude: 103.707629)
    //    = .init(latitude: 1.355670, longitude: 103.748648)
    
    @State private var destinationPoint: CLLocationCoordinate2D?
    //    = .init(latitude: 1.320865, longitude: 103.828507)
    //    = .init(latitude: 1.381543, longitude: 103.845154)
    //    = .init(latitude: 1.321100, longitude: 103.821680)
    
    @State private var isLoading: Bool = false
    
    private var journeyPlanner: JourneyPlanner {
        JourneyPlanner.shared
    }
    
    private let region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), // Singapore's coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.21, longitudeDelta: 0.21) // Zoom level
    )
    
    @State private var plannedJourneys: [[JourneyComponent]]?
    @State private var selectedJourneyIndex: Int?
    @State private var showJourneyDetail: Bool = false
    
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
    
    func mapTripsWithStops(components: [JourneyComponent]) -> [JourneyViewComponent] {
        guard components.count >= 3 else { return [] }
        var results: [JourneyViewComponent] = []
        let firstStop = components[0].stop
        let distance = Int(sqrt(startingPoint!.point.squaredDistance(to: firstStop.point)))
        let start = Stop(id: "start", code: "", latitude: startingPoint!.latitude, longitude: startingPoint!.longitude, name: "Starting Point", url: "", wheelchairBoarding: false)
        results.append(.walking(distance: distance, start: start, destination: firstStop))
        
        let ultDestination = Stop(id: "destination", code: "", latitude: destinationPoint!.latitude, longitude: destinationPoint!.longitude, name: "Destination Point", url: "", wheelchairBoarding: false)
        
        for i in 1..<components.count - 1 {
            if case let .stop(start) = components[i - 1],
               case let .stop(destination) = components[i + 1] {
                if case let .trip(trip) = components[i] {
                    results.append(.trip(trip, start: start, destination: destination))
                    if i == components.count - 2 {
                        let distance = Int(sqrt(destination.point.squaredDistance(to: ultDestination.point)))
                        results.append(.walking(distance: distance, start: destination, destination: ultDestination))
                    }
                }
                else if case var .walking(distance) = components[i] {
                    if i == components.count - 2 {
                        distance = Int(sqrt(ultDestination.point.squaredDistance(to: components[i-1].stop.point)))
                    }
                    let dest = (i != components.count - 2) ? destination : ultDestination
                    results.append(.walking(distance: distance, start: start, destination:  dest))
                }
            }
        }
        return results
    }
    
    var loadingView: some View {
        VStack {
            Text("One-Time Setup in Progress")
                .font(.headline)
                .padding(.bottom, 10)
            Divider()
            
            Text(oneTimeSetupMessage)
                .font(.callout)
                .padding(.bottom, 10)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
                .padding()
        }
        .padding()
        .frame(maxWidth: isPad ? 420.0 : .infinity)
        .aspectRatio(1.0, contentMode: .fit)
        .background(Color.gray.adjust(by: -42.0))
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding()
    }
    
    var journeyPlannerView: some View {
        ZStack(alignment: isLoading ? .center : .topLeading) {
            MapReader { proxy in
                Map(initialPosition: .region(region)) {
                    if let startingPoint = startingPoint {
                        Marker("Src", coordinate: startingPoint)
                    }
                    if let destinationPoint = destinationPoint {
                        Marker("Dst", coordinate: destinationPoint)
                    }
                    
                    if let tripIndex = selectedJourneyIndex,
                       let selectedTrip = plannedJourneys?[tripIndex]
                    {
                        let viewComponents = mapTripsWithStops(components: selectedTrip)
                        
                        ForEach(viewComponents) { component in
                            switch component {
                            case .trip(let trip, let start, let destination):
                                let points = getPoints(of: trip, between: start, and: destination)
                                MapPolyline(points: points)
                                    .stroke(trip.isRailway ? .purple : .blue, lineWidth: 8.0)
                                
                                let tripImage = trip.isRailway ?  "tram.fill.tunnel" : "bus"
                                Marker(start.name, systemImage: tripImage, coordinate: start.coordinate)
                                    .tint(trip.isRailway ? .purple.adjust(by: -20.0) : .blue.adjust(by: -20.0))
                                
                            case .walking(_, let start, let destination):
                                let points = [start.coordinate, destination.coordinate].map {
                                    MKMapPoint($0)
                                }
                                MapPolyline(points: points)
                                    .stroke(.yellow, style: StrokeStyle(lineWidth: 8.0, dash: [4.0, 2.0]))
                                Marker(start.name, systemImage: "figure.walk", coordinate: start.coordinate)
                            }
                        }
                    }
                }
                .disabled(isLoading)
                .onTapGesture { touchPosition in
                    if let touchPoint = proxy.convert(touchPosition, from: .local) {
                        if startingPoint == nil {
                            self.startingPoint = touchPoint
                        }
                        else if destinationPoint == nil {
                            self.destinationPoint = touchPoint
                        }
                        if let start = startingPoint, let destination = destinationPoint {
                            self.plannedJourneys = journeyPlanner.findJourneys(from: start, to: destination)
                            self.selectedJourneyIndex = 0
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Trip Planner")
            
            if isLoading {
                loadingView
            }
            else {
                VStack(alignment: .leading) {
                    Button {
                        withAnimation {
                            self.startingPoint = nil
                            self.plannedJourneys = nil
                            self.selectedJourneyIndex = nil
                            self.showJourneyDetail = false
                        }
                    } label: {
                        VStack {
                            if let startingPoint = startingPoint {
                                Text("Starting point: " + startingPoint.coordinateText)
                                    .foregroundStyle(.white)
                                Text("Tap to deselect starting point")
                                    .font(.caption)
                                    .foregroundStyle(.white.adjust(by: -20.0))
                            }
                            else {
                                Text("Touch on the map to select the starting point")
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: 320.0)
                        .padding(12.0)
                        .background(.gray.adjust(by: -42.0))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                    }
                    .disabled(startingPoint == nil)
                    
                    Button {
                        withAnimation {
                            self.destinationPoint = nil
                            self.plannedJourneys = nil
                            self.selectedJourneyIndex = nil
                            self.showJourneyDetail = false
                        }
                    } label: {
                        VStack {
                            if let destinationPoint = destinationPoint {
                                Text("Destination point: " + destinationPoint.coordinateText)
                                    .foregroundStyle(.white)
                                Text("Tap to deselect destination point")
                                    .font(.caption)
                                    .foregroundStyle(.white.adjust(by: -20.0))
                            }
                            else if startingPoint != nil {
                                Text("Touch on the map to select the destination point")
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(maxWidth: 320.0)
                        .padding(12.0)
                        .background(.gray.adjust(by: -42.0))
                        .clipShape(RoundedRectangle(cornerRadius: 8.0))
                        .opacity(destinationPoint == nil && startingPoint == nil ? 0 : 1)
                    }
                    .disabled(destinationPoint == nil)
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding()
            }
        }
        .overlay(alignment: .bottom) {
            if let index = selectedJourneyIndex,
               let journey = plannedJourneys?[index]
            {
                let journeyView = mapTripsWithStops(components: journey)
                if showJourneyDetail {
                    JourneyDetailView(journey: journeyView, showDetail: $showJourneyDetail)
                }
                else {
                    let _plannedJourneys = plannedJourneys?.compactMap { mapTripsWithStops(components: $0) }
                    JourneyListView(for: _plannedJourneys, selectedJourneyIndex: $selectedJourneyIndex, showDetail: $showJourneyDetail)
                }
            }
        }
    }
    
    var body: some View {
        journeyPlannerView
            .onAppear {
                isLoading = initialSetupRequired
                Task {
                    JourneyPlanner.shared = await JourneyPlanner(modelContext: modelContext)
                    isLoading = false
                }
            }
    }
}
