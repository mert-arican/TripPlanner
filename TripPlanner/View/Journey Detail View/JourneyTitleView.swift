//
//  JourneyTitleView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 27.01.2025.
//

import SwiftUI

struct JourneyTitleView: View {
    let journey: [JourneyViewComponent]
    
    init(for journey: [JourneyViewComponent]) {
        self.journey = journey
    }
    
    var body: some View {
        HStack {
            HStack {
                ForEach(journey) { component in
                    switch component {
                    case .trip(let trip,_,_):
                        JourneyMonogram(for: trip)
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
}
