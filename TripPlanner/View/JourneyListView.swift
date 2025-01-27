//
//  RouteListView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 24.01.2025.
//

import SwiftUI
import SwiftData

struct JourneyListView: View {
    let plannedJourneys: [[JourneyViewComponent]]?
    @Binding var showJourneyDetail: Bool
    
    init(for plannedJourneys: [[JourneyViewComponent]]?, showJourneyDetail: Binding<Bool>) {
        self.plannedJourneys = plannedJourneys
        self._showJourneyDetail = showJourneyDetail
    }
    
    var body: some View {
        if let plannedJourneys = plannedJourneys {
//            ScrollView {
//                VStack {
//                    Text("Planned Journeys")
//                        .font(.title)
                    
                    List {
                        Section(header: Text("Planned Journeys").font(.title2).padding(.bottom)) {
                            ForEach(plannedJourneys.indices, id: \.self) { index in
                                Button {
                                    showJourneyDetail = true
                                } label: {
                                    JourneyTitleView(for: plannedJourneys[index])
                                }
                                .listRowBackground(index == 0 ? Color.yellow : .gray.adjust(by: -42.0))
                            }
                        }
                    }
//                }
//            }
            .frame(maxWidth: .infinity, maxHeight: isPad ? 420.0 : 210.0)
        }
    }
}
