//
//  DiaryEntry.swift
//  Balance
//
//  Created by Sabrina Bea on 3/29/24.
//

import Foundation

struct DiaryEntry: DatabaseObject, Equatable {
    let id: UUID
    let title: String
    let date: Date
    let meal: Meal
    let foodId: UUID
    let weightMeasurement: Measurement<WeightUnit>?
    let volumeMeasurement: Measurement<VolumeUnit>?
    let calories: Int
    
    var measurementDescription: String {
        if let weightMeasurement = weightMeasurement {
            return weightMeasurement.description
        }
        if let volumeMeasurement = volumeMeasurement {
            return volumeMeasurement.description
        }
        return "(Corrupted)"
    }
    
    static var forPreview: DiaryEntry {
        return DiaryEntry()
    }
    
    init(id: UUID = UUID(), date: Date, title: String, meal: Meal, foodId: UUID, weightMeasurement: Measurement<WeightUnit>?, volumeMeasurement: Measurement<VolumeUnit>?, calories: Int) {
        self.id = id
        self.title = title
        self.date = date
        self.meal = meal
        self.foodId = foodId
        self.weightMeasurement = weightMeasurement
        self.volumeMeasurement = volumeMeasurement
        self.calories = calories
    }
    
    init(date: Date, meal: Meal, food: Food, weightMeasurement: Measurement<WeightUnit>?, volumeMeasurement: Measurement<VolumeUnit>?) {
        self.init(
            date: date,
            title: food.name,
            meal: meal,
            foodId: food.id,
            weightMeasurement: weightMeasurement,
            volumeMeasurement: volumeMeasurement,
            calories: food.calories(byWeight: weightMeasurement, byVolume: volumeMeasurement))
    }
    
    init(renaming diaryEntry: DiaryEntry, to title: String, withFoodId foodId: UUID? = nil) {
        self.init(id: diaryEntry.id, date: diaryEntry.date, title: title, meal: diaryEntry.meal, foodId: foodId ?? diaryEntry.foodId, weightMeasurement: diaryEntry.weightMeasurement, volumeMeasurement: diaryEntry.volumeMeasurement, calories: diaryEntry.calories)
    }
    
    // Convenience initializer for test data
    init(date: Date = Date(), meal: Meal = .breakfast, food: Food? = nil, grams: Double? = nil, milliliters: Double? = nil) {
        self.init(
            date: date,
            meal: meal,
            food: food ?? Food(grams: grams, milliliters: milliliters),
            weightMeasurement: grams == nil ? nil : Measurement(type: .weight, unit: .gram, amount: grams!),
            volumeMeasurement: milliliters == nil ? nil : Measurement(type: .volume, unit: .milliliter, amount: milliliters!)
        )
    }
}
