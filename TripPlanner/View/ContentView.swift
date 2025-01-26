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
            NavigationStack {
                JourneyPlannerView()
            }
            .tabItem {
                Label("Trip Planner", systemImage: "xmark")
            }
            .tag(1)
//            NavigationStack {
//                RouteListView()
//            }
//            .tabItem {
//                Label("Routes", systemImage: "xmark")
//            }
//            .tag(2)
        }
        .onAppear {
            JourneyPlanner.shared = JourneyPlanner(modelContext: modelContext)
        }
    }
}

#Preview {
    ContentView()
}
