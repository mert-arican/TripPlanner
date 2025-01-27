//
//  JourneyDetailView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import SwiftUI

struct JourneyDetailView: View {
    let journey: [JourneyViewComponent]
    @Binding var showDetail: Bool
    
    private var journeyPlanner: JourneyPlanner {
        .shared
    }
    
    private func getStopCount(for trip: Trip, between start: Stop, and destination: Stop) -> Int {
        return journeyPlanner.stopTimeOrder[trip.id]![destination.id]! - journeyPlanner.stopTimeOrder[trip.id]![start.id]!
    }
    
    private func getTimes(for trip: Trip, between start: Stop, and destination: Stop) -> String {
        return journeyPlanner.stopTimes[trip.id]![start.id]!.arrivalTime + " " + journeyPlanner.stopTimes[trip.id]![destination.id]!.arrivalTime
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            JourneyTitleView(for: journey, showDetail: $showDetail)
                .padding()
                .padding(.leading)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "circle")
                            .scaleEffect(1.2)
                        
                        Text("Starting Point")
                            .font(.title2)
                            .padding(.leading)
                    }
                    ForEach(journey) { component in
                        switch component {
                        case .trip(let trip, start: let start, destination: let destination):
                            HStack {
                                VStack(spacing: 0.0) {
                                    Image(systemName: trip.isRailway ? "tram.fill.tunnel" : "bus")
                                        .background(
                                            RoundedRectangle(cornerRadius: 4.2)
                                                .fill(trip.isRailway ? .purple : .blue) // Background color
                                                .scaleEffect(1.2)
                                        )
                                        .padding(.vertical, 2.0)
                                    Rectangle().fill(trip.isRailway ? .purple : .blue).frame(width: 12.0).zIndex(-100)
                                    Image(systemName: "smallcircle.filled.circle")
                                        .background(
                                            Circle()
                                                .fill(trip.isRailway ? .purple : .blue) // Background color
                                                .scaleEffect(1.2)
                                        )
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(start.name)
                                        .font(.title2)
                                    Spacer()
                                    
                                    if isPad {
                                        HStack {
                                            JourneyMonogram(for: trip)
                                            Text("| \(getStopCount(for: trip, between: start, and:destination)) Stops")
//                                            Text(" | \(getTimes(for: trip, between: start, and:destination))")
                                        }
                                    }
                                    else { // is iPhone
                                        VStack {
                                            JourneyMonogram(for: trip)
                                            Text("\(getStopCount(for: trip, between: start, and:destination)) Stops")
                                        }
                                    }
                                    Spacer()
                                    Text(destination.name)
                                        .font(.title2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                            }
                            .frame(height: 180.0)
                            .padding(.vertical, 4.2)
                            
                        case .walking(let distance,_,_):
                            if distance != 0 {
                                HStack {
                                    VStack {
                                        ZStack {
                                            Rectangle().fill(.gray).frame(width: 1.0)
                                            
                                            Image(systemName: "bus")
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8.0)
                                                        .fill(.blue) // Background color
                                                        .scaleEffect(1.2)
                                                )
                                                .opacity(0.0) // Trick to center things vertically
                                        }
                                        Image(systemName: "figure.walk")
                                        ZStack {
                                            Rectangle().fill(.gray).frame(width: 1.0)
                                            Image(systemName: "bus")
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8.0)
                                                        .fill(.blue) // Background color
                                                        .scaleEffect(1.2)
                                                )
                                                .opacity(0.0) // Trick to center things vertically
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Divider()
                                        
                                        Text("Walk \(distance) m | \(distance/83) min")
                                            .font(.callout)
                                            .padding(.vertical)
                                        
                                        Divider()
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                }
                                .frame(height: 80.0)
                                .padding(.vertical, 4.2)
                            }
                        }
                    }
                    HStack {
                        Image(systemName: "mappin.circle")
                            .scaleEffect(1.2)
                        
                        Text("Destination Point")
                            .font(.title2)
                            .padding(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: isPad ? 420.0 : 210.0)
        .background(.gray.adjust(by: -42.0))
    }
}

//#Preview {
//    JourneyDetailView()
//}
