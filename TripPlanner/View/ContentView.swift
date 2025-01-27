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
    // MARK: TODO:
    // Initial load info
    // Coordinate buttons
    
    var body: some View {
        TabView {
            NavigationStack {
                JourneyPlannerView()
            }
            .tabItem {
                Label("Trip Planner", systemImage: "map")
            }
            .tag(1)
        }
    }
}

#Preview {
    ContentView()
}
