//
//  Unit.swift
//  Balance
//
//  Created by Sabrina Bea on 3/29/24.
//

import Foundation

protocol DisplayableUnit: Codable, Equatable {
    var displayName: String { get }
    var abbreviation: String { get }
    
    func toStandard(_ amount: Double) -> Double
    func fromStandard(_ amount: Double) -> Double
}

enum WeightUnit: String, DisplayableUnit, Codable, CaseIterable {
    case gram, kilogram, ounce, pound
    
    var displayName: String {
        switch self {
        case .gram:
            return "grams"
        case .kilogram:
            return "kilograms"
        case .ounce:
            return "ounces"
        case .pound:
            return "pounds"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .gram:
            return "g"
        case .kilogram:
            return "kg"
        case .ounce:
            return "oz"
        case .pound:
            return "lb"
        }
    }
    
    func toGrams(_ amount: Double) -> Double {
        switch self {
        case .gram:
            return amount
        case .kilogram:
            return amount * 1000
        case .ounce:
            return amount * 28.3495
        case .pound:
            return amount * 453.592
        }
    }
    
    func fromGrams(_ amount: Double) -> Double {
        switch self {
        case .gram:
            return amount
        case .kilogram:
            return amount / 1000
        case .ounce:
            return amount / 28.3495
        case .pound:
            return amount / 453.592
        }
    }
    
    func toStandard(_ amount: Double) -> Double {
        return toGrams(amount)
    }
    
    func fromStandard(_ amount: Double) -> Double {
        return fromGrams(amount)
    }
}

enum VolumeUnit: String, DisplayableUnit, Codable, CaseIterable {
    case milliliter, liter, teaspoon, tablespoon, fluidOunce, cup, pint, quart, gallon, piece
    
    var displayName: String {
        switch self {
        case .milliliter:
            return "milliliters"
        case .liter:
            return "liters"
        case .teaspoon:
            return "teaspoons"
        case .tablespoon:
            return "tablespoons"
        case .fluidOunce:
            return "fluid ounces"
        case .cup:
            return "cups"
        case .pint:
            return "pints"
        case .quart:
            return "quarts"
        case .gallon:
            return "gallons"
        case .piece:
            return "pieces"
        }
    }
    
    var abbreviation: String {
        switch self {
        case .milliliter:
            return "mL"
        case .liter:
            return "L"
        case .teaspoon:
            return "tsp"
        case .tablespoon:
            return "tbsp"
        case .fluidOunce:
            return "fl oz"
        case .cup:
            return "c"
        case .pint:
            return "pt"
        case .quart:
            return "qt"
        case .gallon:
            return "gal"
        case .piece:
            return "pc"
        }
    }
    
    func toMilliliters(_ amount: Double) -> Double {
        switch self {
        case .milliliter:
            return amount
        case .liter:
            return amount * 1000
        case .teaspoon:
            return amount * 4.92892
        case .tablespoon:
            return amount * 14.7868
        case .fluidOunce:
            return amount * 29.5735
        case .cup:
            return amount * 236.588
        case .pint:
            return amount * 473.176
        case .quart:
            return amount * 946.353
        case .gallon:
            return amount * 3785.41
        case .piece:
            return amount * 473.176 // Was encoded as pint (because pt looks like part), so now needs this for calories to be right
        }
    }
    
    func fromMilliliters(_ amount: Double) -> Double {
        switch self {
        case .milliliter:
            return amount
        case .liter:
            return amount / 1000
        case .teaspoon:
            return amount / 4.92892
        case .tablespoon:
            return amount / 14.7868
        case .fluidOunce:
            return amount / 29.5735
        case .cup:
            return amount / 236.588
        case .pint:
            return amount / 473.176
        case .quart:
            return amount / 946.353
        case .gallon:
            return amount / 3785.41
        case .piece:
            return amount / 473.176 // Was encoded as pint (because pt looks like part), so now needs this for calories to be right
        }
    }
    
    func toStandard(_ amount: Double) -> Double {
        return toMilliliters(amount)
    }
    
    func fromStandard(_ amount: Double) -> Double {
        return fromMilliliters(amount)
    }
}

enum MeasurementType: String, Codable, CaseIterable, Equatable {
    case weight = "Weight"
    case volume = "Volume"
}

struct Measurement<Unit: DisplayableUnit>: Codable, Equatable {
    let type: MeasurementType
    let unit: Unit
    let amount: Double
    
    var description: String {
        "\(amount.formattedString) \(unit.abbreviation)"
    }
    
    func toStandard() -> Double {
        return unit.toStandard(amount)
    }
    
    func fromStandard() -> Double {
        return unit.fromStandard(amount)
    }
}
