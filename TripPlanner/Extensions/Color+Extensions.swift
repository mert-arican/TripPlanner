//
//  Color+AdjustBy.swift
//  Felix
//
//  Created by Mert Arıcan on 19.03.2023.
//

import Foundation
import SwiftUI
import UIKit

extension Color {
    func adjust(by percentage: CGFloat = 30.0) -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        if (UIColor(self)).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(UIColor(red: min(red + percentage/100, 1.0),
                         green: min(green + percentage/100, 1.0),
                         blue: min(blue + percentage/100, 1.0), alpha: alpha))
        }
        return self
    }
}
