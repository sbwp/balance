//
//  EstimationMode.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import Foundation

enum EstimationMode: String, CaseIterable {
    case none = "Off"
    case restingOnly = "Resting Only"
    case burnOnly = "Burn Only"
    case all = "All"
    
    var explanation: String {
        switch self {
        case .none:
            return "No future calories will estimated."
        case .restingOnly:
            return "Resting energy will be estimated based on the past 7 days."
        case .burnOnly:
            return "Resting and active energy will be estimated based on the past 7 days."
        case .all:
            return "Resting, active, and dietary energy will be estimated based on the past 7 days."
        }
    }
}
