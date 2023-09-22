//
//  NeatEstimationMode.swift
//  Balance
//
//  Created by Sabrina Bea on 9/20/23.
//

import Foundation

enum NeatEstimationMode: String, CaseIterable {
    case off
    case mean
    case minimum
    
    var explanation: String {
        switch self {
        case .off:
            return "\(EnergyType.nonexercise.descriptiveName) will not be estimated for the remainder of the day."
        case .mean:
            return "\(EnergyType.nonexercise.descriptiveName) for the remainder of the day will be estimated as the mean value over the last seven days for each hour."
        case .minimum:
            return "\(EnergyType.nonexercise.descriptiveName) for the remainder of the day will be estimated as the minimum value over the last seven days for each hour."
        }
    }
    
    var descriptiveName: String {
        switch self {
            case .off: return "Off"
            case .mean: return "Mean"
            case .minimum: return "Minimum"
        }
    }
}
