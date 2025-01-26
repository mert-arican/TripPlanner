//
//  JourneyDetailView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 26.01.2025.
//

import SwiftUI

struct JourneyDetailView: View {
    let journey: [JourneyViewComponent]
    
    private var titleView: some View {
        HStack {
            HStack {
                ForEach(journey) { component in
                    switch component {
                    case .trip(let trip,_,_):
                        HStack {
                            Image(systemName: trip.isRailway ? "tram.fill.tunnel" : "bus")
                            Text(trip.routeID.uppercased())
                        }
                        .padding(4.2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2.1)
                                .stroke(.gray.adjust(by: 42.0), lineWidth: 0.42)
                        )
                    case .walking(_,_,_):
                        HStack {
                            Image(systemName: "figure.walk")
                        }
                    }
                    if component.id != journey.last?.id {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding(8.0)
            .background(.gray.adjust(by: -46.0))
            .clipShape(
                RoundedRectangle(cornerRadius: 8.0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8.0)
                    .stroke(.gray.adjust(by: 20.0), lineWidth: 0.42)
            )
            
            Spacer()
            
            Image(systemName: "xmark")
                .padding()
        }
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            titleView
                .padding()
                .padding(.leading)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(journey) { component in
                        
                        // MARK: TODO: Beautiful UI
                        switch component {
                        case .trip(let trip, start: let start, destination: let destination):
                            Text(trip.routeID)
                            Text(start.name)
                            Text(destination.name)
                            
                        case .walking(let distance, let start, let destination):
                            Text("\(distance) m")
                            Text(start.name)
                            Text(destination.name)
                        }
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
