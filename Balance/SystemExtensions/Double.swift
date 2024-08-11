//
//  Double.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import Foundation

extension Double {
    var formattedString: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
    
    func isGreaterThan(_ value: Double, byDelta delta: Double) -> Bool {
        return self - value > delta
    }
    
    func isLessThan(_ value: Double, byDelta delta: Double) -> Bool {
        return value.isGreaterThan(self, byDelta: delta)
    }
    
    func approximatelyEquals(_ value: Double, withinDelta delta: Double) -> Bool {
        return (self - value).magnitude < delta
    }
}
