//
//  TripPlannerApp.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 20.01.2025.
//

import SwiftUI
import SwiftData

@main
struct TripPlannerApp: App {
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Agency.self,
                GTFSCalendar.self,
                Frequency.self,
                Route.self,
                GTFSShape.self,
                StopTime.self,
                Stop.self,
                Transfer.self,
                Trip.self
            ])
        
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
                .preferredColorScheme(.dark)
        }
    }
}
