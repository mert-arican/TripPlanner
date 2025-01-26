//
//  RouteComponent.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 21.01.2025.
//

import Foundation

enum JourneyComponent: Equatable, Hashable, CustomStringConvertible {
    case walking(distance: Int)
    case stop(Stop)
    case trip(Trip)
    
    static func ==(_ lhs: JourneyComponent, _ rhs: Trip) -> Bool {
        switch lhs {
        case .trip(let trip): trip.routeID == rhs.id
        default: false
        }
    }
    
    static func ==(_ lhs: JourneyComponent, _ rhs: Route) -> Bool {
        switch lhs {
        case .trip(let trip): trip.routeID == rhs.id
        default: false
        }
    }
    
    static func ==(_ lhs: JourneyComponent, _ rhs: Stop) -> Bool {
        switch lhs {
        case .stop(let stop): stop.id == rhs.id
        default: false
        }
    }
    
    var stop: Stop {
        switch self {
        case .stop(let stop):
            return stop
        default:
            fatalError()
        }
    }
    
    var routeID: String {
        switch self {
        case .trip(let trip):
            return trip.routeID
        default:
            fatalError()
        }
    }
    
    var trip: Trip {
        switch self {
        case .trip(let trip):
            return trip
        default:
            fatalError()
        }
    }
    
    var type: Int {
        switch self {
        case .walking(_):
            return 0
        case .stop(_):
            return 1
        case .trip(_):
            return 2
        }
    }
    
    var distance: Int {
        switch self {
        case .walking(let distance):
            return distance
        default: return 0
        }
    }
    
    var description: String {
        switch self {
        case .walking(let distance):
            "Walking of distance: \(distance)"
        case .stop(let stop):
            "Stop: \(stop.name)"
        case .trip(let trip):
            "Trip: \(trip.id)"
        }
    }
}
