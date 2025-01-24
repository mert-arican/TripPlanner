//
//  RouteListView.swift
//  TripPlanner
//
//  Created by Mert Arıcan on 24.01.2025.
//

import SwiftUI
import SwiftData

struct RouteListView: View {
    @Query private var routes: [Route]
    
    var body: some View {
        List {
            ForEach(routes) { route in
                Text(route.id)
            }
        }
    }
}

#Preview {
    RouteListView()
}
