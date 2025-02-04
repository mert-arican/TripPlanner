//
//  TripPlannerTests.swift
//  TripPlannerTests
//
//  Created by Mert Arıcan on 20.01.2025.
//

import XCTest
import SwiftData
@testable import TripPlanner

final class TripPlannerTests: XCTestCase {
    @MainActor
    override func setUpWithError() throws {
        print("setup in")
        if Self.modelContext == nil {
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
            
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            Self.journeyPlanner = JourneyPlanner(modelContext: container.mainContext)
            Self.modelContext = container.mainContext
            print("setup out")
        }
    }
    
    static var journeyPlanner: JourneyPlanner!
    static var modelContext: ModelContext!

    @MainActor func testCalendar() async throws {
        let calendarFetch = FetchDescriptor<GTFSCalendar>()
        let calendars = try? Self.modelContext.fetch(calendarFetch)
        XCTAssertEqual(calendars?.count, 5)
    }
    
    @MainActor func testStops() async throws {
        let calendarFetch = FetchDescriptor<Stop>()
        let calendars = try? Self.modelContext.fetch(calendarFetch)
        XCTAssertEqual(calendars?.count, 5251)
    }

    @MainActor func testTrips() async throws {
        let calendarFetch = FetchDescriptor<Trip>()
        let calendars = try? Self.modelContext.fetch(calendarFetch)
        XCTAssertEqual(calendars?.count, 1772)
    }
    
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}


//
//func asyncSetUpWithError() async throws {
//    fatalError("Must override")
//}
//
//func asyncTearDownWithError() async throws {
//    fatalError("Must override")
//}
//
//override func setUpWithError() async throws {
//    wait {
//        try await self.asyncSetUpWithError()
//    }
//}
//
//override func tearDownWithError() throws {
//    wait {
//        try await self.asyncTearDownWithError()
//    }
//}
//
//func wait(asyncBlock: @escaping (() async throws -> Void)) {
//    let semaphore = DispatchSemaphore(value: 0)
//    Task.init {
//        try await asyncBlock()
//        semaphore.signal()
//    }
//    semaphore.wait()
//}
