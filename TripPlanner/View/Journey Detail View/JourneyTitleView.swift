//
//  JourneyTitleView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 27.01.2025.
//

import SwiftUI

struct JourneyTitleView: View {
    let journey: [JourneyViewComponent]
    let asListItem: Bool
    @Binding var showDetail: Bool
    
    init(for journey: [JourneyViewComponent],
         showDetail: Binding<Bool>,
         asListItem: Bool=false) {
        self.journey = journey
        self._showDetail = showDetail
        self.asListItem = asListItem
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
            if !asListItem {
                Button {
                    showDetail = false
                } label: {
                    Image(systemName: "xmark").padding()
                }
            }
        }
    }
}
