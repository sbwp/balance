//
//  ViewExtensions.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        return clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func unitDropdownFrame() -> some View {
        return frame(maxWidth: 100)
    }
    
    func fullyTappable() -> some View {
        return contentShape(Rectangle())
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
