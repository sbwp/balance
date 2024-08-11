//
//  FoodResultView.swift
//  Balance
//
//  Created by Sabrina Bea on 6/4/24.
//

import SwiftUI

struct FoodResultView: View {
    @EnvironmentObject var pantry: Pantry
    @State var foodEditName = ""
    @State var createdFoodPlaceholder: Food? = nil
    @State var showCannotDeleteAlert: Bool = false
    let food: Food
    
    var body: some View {
        HStack {
            Text(food.name)
            Spacer()
            Text("\(food.calories)")
        }
        .contextMenu(ContextMenu(menuItems: {
            NavigationLink {
                CreateFoodView(name: $foodEditName, createdFood: $createdFoodPlaceholder, oldFood: food)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive) {
                Task.detached { @MainActor in
                    if (try? await pantry.deleteFood(food)) == nil {
                        showCannotDeleteAlert = true
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        }))
        .alert(isPresented: $showCannotDeleteAlert) {
            Alert(title: Text("Food in Use"), message: Text("The food \(food.name) cannot be deleted because it is being used in one or more past diary entries."))
        }
    }
}

#Preview {
    FoodResultView(food: Food("Toast", 250, weightMeasurement: Measurement(type: .weight, unit: .gram, amount: 500), volumeMeasurement: nil, defaultMeasurement: .weight))
        .environmentObject(Pantry())
}
