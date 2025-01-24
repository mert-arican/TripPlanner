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
    
    var body: some View {
        TabView {
            TripPlannerView()
                .tabItem {
                    Label("Trip Planner", systemImage: "xmark")
                }
            RouteListView()
                .tabItem {
                    Label("Routes", systemImage: "xmark")
                }
        }
        .onAppear {
            TripPlanner.shared = TripPlanner(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}

extension GTFSShape {    
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
    var point: CGPoint { coordinate.point }
}
