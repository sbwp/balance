//
//  Food.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import Foundation

struct Food: DatabaseObject, Equatable {
    let id: UUID
    let name: String
    let calories: Int
    let gPerServing: Double?
    let mlPerServing: Double?
    let defaultWeightUnit: WeightUnit?
    let defaultVolumeUnit: VolumeUnit?
    let defaultMeasurement: MeasurementType
    
    init(_ name: String, _ cal: Int, weightMeasurement: Measurement<WeightUnit>?, volumeMeasurement: Measurement<VolumeUnit>?, defaultMeasurement: MeasurementType, id: UUID = UUID()) {
        self.id = id
        self.name = name
        self.calories = cal
        self.defaultMeasurement = defaultMeasurement
        
        self.defaultWeightUnit = weightMeasurement?.unit
        self.gPerServing = weightMeasurement?.unit.toGrams(weightMeasurement!.amount)
        
        self.defaultVolumeUnit = volumeMeasurement?.unit
        self.mlPerServing = volumeMeasurement?.unit.toMilliliters(volumeMeasurement!.amount)
    }
    
    // Convenience initializer for test data
    init(_ name: String = "Nachos", _ calories: Int = 500, grams: Double? = nil, milliliters: Double? = nil, defaultMeasurement: MeasurementType? = nil) {
        let gramsFilled = (grams == nil && milliliters == nil) ? 500 : grams
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.defaultMeasurement = defaultMeasurement ?? (grams == nil ? .volume : .weight)
        self.defaultWeightUnit = gramsFilled == nil ? nil : .gram
        self.defaultVolumeUnit = milliliters == nil ? nil : .milliliter
        self.gPerServing = gramsFilled
        self.mlPerServing = milliliters
    }
    
    func calories(byWeight: Measurement<WeightUnit>? = nil, byVolume: Measurement<VolumeUnit>? = nil) -> Int {
        var caloriesPerUnit: Double = 0
        if let weightMeasurement = byWeight, let gPerServing = gPerServing {
            caloriesPerUnit = weightMeasurement.toStandard() / gPerServing
        }
        
        if let volumeMeasurement = byVolume, let mlPerServing = mlPerServing {
            caloriesPerUnit = volumeMeasurement.toStandard() / mlPerServing
        }
        
        let calories = (Double(calories) * caloriesPerUnit).rounded()
        return calories.isFinite ? Int(calories) : 0
    }
}
