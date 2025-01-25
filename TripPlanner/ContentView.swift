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
    @State var selection = 1
    
    var body: some View {
        TabView {
            NavigationStack {
                TripPlannerView()
            }
            .tabItem {
                Label("Trip Planner", systemImage: "xmark")
            }
            .tag(1)
            
            NavigationStack {
                RouteListView()
            }
            .tabItem {
                Label("Routes", systemImage: "xmark")
            }
            .tag(2)
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
