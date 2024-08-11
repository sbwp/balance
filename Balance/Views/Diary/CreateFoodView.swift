//
//  CreateFoodView.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import SwiftUI

struct CreateFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var pantry: Pantry
    @State var calories: Int? = nil
    @State var measureBy: MeasureByOption = .weight
    @State var servingSizeByWeight: Double? = nil
    @State var weightUnit: WeightUnit = .gram
    @State var servingSizeByVolume: Double? = nil
    @State var volumeUnit: VolumeUnit = .milliliter
    @State var defaultMeasurement: MeasurementType = .weight
    @State var showValidationText = false
    
    @Binding var name: String
    @Binding var createdFood: Food?
    let oldFood: Food?
    
    init(name: Binding<String>, createdFood: Binding<Food?>, oldFood: Food? = nil) {
        self._name = name
        self._createdFood = createdFood
        self.oldFood = oldFood
    }
    
    var body: some View {
        Form {
            if showValidationText {
                Text("Please ensure all required fields are filled and try again")
            }
            TextField("Name", text: $name)
            IntegerField("Calories per serving", value: $calories)
            
            Picker("Measure by", selection: $measureBy) {
                ForEach(MeasureByOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            
            if measureBy != .volume {
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
            
            if measureBy != .weight {
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
            
            if measureBy == .both {
                Picker("Default to", selection: $defaultMeasurement) {
                    ForEach(MeasurementType.allCases, id: \.self) { option in
                        Text(option.rawValue)
                    }
                }
            }
        }
        .onAppear {
            if let oldFood = oldFood {
                name = oldFood.name
                calories = oldFood.calories
                measureBy = getMeasureBy(food: oldFood)
                weightUnit = oldFood.defaultWeightUnit ?? .gram
                volumeUnit = oldFood.defaultVolumeUnit ?? .milliliter
                servingSizeByWeight = destandardize(standardValue: oldFood.gPerServing, unit: weightUnit)
                servingSizeByVolume = destandardize(standardValue: oldFood.mlPerServing, unit: volumeUnit)
                defaultMeasurement = oldFood.defaultMeasurement
            }
        }
        .navigationTitle(oldFood == nil ? "Create Food" : "Edit \(oldFood!.name)")
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
                    let defaultMeasurementComputed = getDefaultMeasurement()
                    
                    Task.detached { @MainActor in
                        let id = oldFood?.id ?? UUID()
                        let food = Food(name, calories!, weightMeasurement: weightMeasurement, volumeMeasurement: volumeMeasurement, defaultMeasurement: defaultMeasurementComputed, id: id)
                        await pantry.addOrUpdateFood(food)
                        createdFood = food
                        name = ""
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getDefaultMeasurement() -> MeasurementType {
        switch measureBy {
        case .weight:
            return .weight
        case .volume:
            return .volume
        case .both:
            return defaultMeasurement
        }
    }
    
    private func getWeightMeasurement() -> Measurement<WeightUnit>? {
        switch measureBy {
        case .weight, .both:
            return Measurement(type: .weight, unit: weightUnit, amount: servingSizeByWeight ?? 0);
        case .volume:
            return nil
        }
    }
    
    private func getVolumeMeasurement() -> Measurement<VolumeUnit>? {
        switch measureBy {
        case .volume, .both:
            return Measurement(type: .volume, unit: volumeUnit, amount: servingSizeByVolume ?? 0);
        case .weight:
            return nil
        }
    }
    
    private func destandardize(standardValue: Double?, unit: any DisplayableUnit) -> Double? {
        guard let standardValue = standardValue else {
            return nil
        }
        return unit.fromStandard(standardValue)
    }
    
    private func getMeasureBy(food: Food) -> MeasureByOption {
        return food.defaultWeightUnit != nil
        ? (food.defaultVolumeUnit != nil ? .both : .weight)
        : .volume
    }
    
    private func valid() -> Bool {
        if measureBy != .volume && servingSizeByWeight == nil {
            return false
        }
        
        if measureBy != .weight && servingSizeByVolume == nil {
            return false
        }
        
        if calories == nil {
            return false
        }
        
        if name.isEmpty {
            return false
        }
        
        return true
    }
}

#Preview {
    NavigationStack{
        CreateFoodView(name: .constant(""), createdFood: .constant(nil))
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack{
        CreateFoodView(name: .constant(""), createdFood: .constant(nil), oldFood: Food())
            .navigationBarTitleDisplayMode(.inline)
    }
}
