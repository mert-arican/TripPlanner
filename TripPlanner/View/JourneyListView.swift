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
    @Binding var selectedJourneyIndex: Int?
    @Binding var showDetail: Bool
    
    init(for plannedJourneys: [[JourneyViewComponent]]?,
         selectedJourneyIndex: Binding<Int?>,
         showDetail: Binding<Bool>
    ) {
        self.plannedJourneys = plannedJourneys
        self._selectedJourneyIndex = selectedJourneyIndex
        self._showDetail = showDetail
    }
    
    var body: some View {
        if let plannedJourneys = plannedJourneys {
            VStack {
                HStack {
                    Text("Planned Trips").font(.title)
                    Spacer()
                    Button {
                        showDetail = true
                    } label: {
                        Text("Start")
                            .font(.callout)
                            .padding(.vertical, 10.0)
                            .padding(.horizontal)
                            .padding(.horizontal)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 8.0)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.0)
                                    .stroke(.gray.adjust(by: 20.0), lineWidth: 0.42)
                            )
                    }
                }
                .padding()
                
                Divider()
                
                List {
                    ForEach(plannedJourneys.indices, id: \.self) { index in
                        Button {
                            selectedJourneyIndex = index
                        } label: {
                            JourneyTitleView(for: plannedJourneys[index], showDetail: .constant(false), asListItem: true)
                        }
                        .listRowBackground(index == selectedJourneyIndex ? Color.yellow : .gray.adjust(by: -42.0))
                    }
                }
                .buttonStyle(.listRow)
            }
            .background(Color.black)
            .frame(maxWidth: .infinity, maxHeight: isPad ? 420.0 : 210.0)
        }
    }
}

struct ListRowButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
        // to cover the whole length of the cell
            .frame(
                maxWidth: .greatestFiniteMagnitude,
                alignment: .leading)
        // to make all the cell tapable, not just the text
            .contentShape(.rect)
            .background {
                if configuration.isPressed {
                    Rectangle()
                        .fill(.gray.adjust(by: -32.0))
                    // Arbitrary negative padding, adjust accordingly
                        .padding(-40)
                }
            }
    }
}

extension ButtonStyle where Self == ListRowButton {
    static var listRow: Self {
        ListRowButton()
    }
}
