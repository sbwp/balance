//
//  CreateDiaryEntryView.swift
//  Balance
//
//  Created by Sabrina Bea on 6/11/24.
//

import SwiftUI

struct CreateDiaryEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var pantry: Pantry
    @State var measureBy: MeasurementType = .weight
    @State var servingSizeByWeight: Double? = nil
    @State var weightUnit: WeightUnit = .gram
    @State var servingSizeByVolume: Double? = nil
    @State var volumeUnit: VolumeUnit = .milliliter
    @State var showValidationText = false
    
    @Binding var selection: [DiaryEntry]
    let date: Date
    let meal: Meal
    let food: Food
    let oldEntry: DiaryEntry?
    
    init(selection: Binding<[DiaryEntry]>, date: Date, meal: Meal, food: Food) {
        self._selection = selection
        self.oldEntry = nil
        self.date = date
        self.meal = meal
        self.food = food
    }
    
    init(selection: Binding<[DiaryEntry]>, oldEntry: DiaryEntry, food: Food) {
        self._selection = selection
        self.oldEntry = oldEntry
        self.date = oldEntry.date
        self.meal = oldEntry.meal
        self.food = food
    }
    
    var body: some View {
        Form {
            if showValidationText {
                Text("Please ensure all required fields are filled and try again")
            }
            
            Picker("Measure by", selection: $measureBy) {
                if food.gPerServing != nil {
                    Text(MeasurementType.weight.rawValue)
                        .tag(MeasurementType.weight)
                }
                if food.mlPerServing != nil {
                    Text(MeasurementType.volume.rawValue)
                        .tag(MeasurementType.volume)
                }
            }
            
            if measureBy == .weight {
                Section("By Weight") {
                    HStack {
                        DoubleField("Serving size", value: $servingSizeByWeight)
                        Picker("Unit", selection: $weightUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { weightUnit in
                                Text(weightUnit.abbreviation)
                            }
                        }
                        .unitDropdownFrame()
                    }
                }
            }
            
            if measureBy == .volume {
                Section("By Volume") {
                    HStack {
                        DoubleField("Serving size", value: $servingSizeByVolume)
                        Picker("Unit", selection: $volumeUnit) {
                            ForEach(VolumeUnit.allCases, id: \.self) { volumeUnit in
                                Text(volumeUnit.abbreviation)
                            }
                        }
                        .unitDropdownFrame()
                    }
                }
            }
            
            Text("Total Calories: \(getCalories())")
        }
        .navigationTitle("\(oldEntry == nil ? "Add" : "Edit") \(food.name)")
        .toolbar() {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if !valid() {
                        showValidationText = true
                        return
                    }
                    
                    showValidationText = false
                    
                    let weightMeasurement = getWeightMeasurement()
                    let volumeMeasurement = getVolumeMeasurement()
                    
                    selection.append(DiaryEntry(id: oldEntry?.id ?? UUID(), date: date, title: food.name, meal: meal, foodId: food.id, weightMeasurement: weightMeasurement, volumeMeasurement: volumeMeasurement, calories: getCalories()))
                    dismiss()
                }
            }
        }
        .onAppear() {
            if let oldEntry = oldEntry {
                measureBy = oldEntry.weightMeasurement != nil
                    ? .weight
                    : .volume
                servingSizeByWeight = oldEntry.weightMeasurement?.amount
                weightUnit = oldEntry.weightMeasurement?.unit ?? food.defaultWeightUnit ?? .gram
                servingSizeByVolume = oldEntry.volumeMeasurement?.amount
                volumeUnit = oldEntry.volumeMeasurement?.unit ?? food.defaultVolumeUnit ?? .milliliter
            } else {
                measureBy = food.defaultMeasurement
                weightUnit = food.defaultWeightUnit ?? .gram
                volumeUnit = food.defaultVolumeUnit ?? .milliliter
            }
        }
    }
    
    private func getWeightMeasurement() -> Measurement<WeightUnit>? {
        return measureBy == .weight
            ? Measurement(type: .weight, unit: weightUnit, amount: servingSizeByWeight ?? 0)
            : nil
    }
    
    private func getVolumeMeasurement() -> Measurement<VolumeUnit>? {
        return measureBy == .volume
            ? Measurement(type: .volume, unit: volumeUnit, amount: servingSizeByVolume ?? 0)
            : nil
    }
    
    private func getCalories() -> Int {
        return food.calories(byWeight: getWeightMeasurement(), byVolume: getVolumeMeasurement())
    }
    
    private func valid() -> Bool {
        if measureBy == .weight && servingSizeByWeight == nil {
            return false
        }
        
        if measureBy == .volume && servingSizeByVolume == nil {
            return false
        }
        
        return true
    }
}

#Preview {
    CreateDiaryEntryView(selection: .constant([]), date: Date(), meal: .breakfast, food: Food("Ground Beef", 500, weightMeasurement: Measurement(type: .weight, unit: .pound, amount: 0.25), volumeMeasurement: Measurement(type: .volume, unit: .cup, amount: 0.5), defaultMeasurement: .weight))
}
