//
//  BmrEstimationMode.swift
//  Balance
//
//  Created by Sabrina Bea on 9/20/23.
//

import Foundation

enum BmrEstimationMode: String, CaseIterable {
    case off
    case median
    case minimum
    
    var explanation: String {
        switch self {
        case .off:
            return "\(EnergyType.bmr.descriptiveName) will not be estimated for the remainder of the day."
        case .median:
            return "\(EnergyType.bmr.descriptiveName) for the remainder of the day will be estimated as the median value over the last seven days for this time of day."
        case .minimum:
            return "\(EnergyType.bmr.descriptiveName) for the remainder of the day will be estimated as the minimum value over the last seven days for this time of day."
        }
    }
    
    var descriptiveName: String {
        switch self {
            case .off: return "Off"
            case .median: return "Median"
            case .minimum: return "Minimum"
        }
    }
}
