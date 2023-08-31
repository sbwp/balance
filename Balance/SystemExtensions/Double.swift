//
//  Double.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import Foundation

extension Double {
    func isGreaterThan(_ value: Double, byDelta delta: Double) -> Bool {
        return self - value > delta
    }
    
    func approximatelyEquals(_ value: Double, withinDelta delta: Double) -> Bool {
        return (self - value).magnitude < delta
    }
}
