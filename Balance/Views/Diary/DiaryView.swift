//
//  DiaryView.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject var pantry: Pantry
    let date: Date
    let externallyTrackedCalories: Int = 0
    
    var body: some View {
        List {
            ForEach(Meal.allCases, id: \.self) { meal in
                Section {
                    ForEach(pantry.getMeal(date: date, meal: meal)) { entry in
                        DiaryEntryView(diaryEntry: entry)
                    }
                } header: {
                    HStack {
                        Text(meal.rawValue.capitalized)
                        Text("(\(pantry.calories(on: date, for: meal)))")
                            .opacity(0.6)
                        Spacer()
                        NavigationLink {
                            TrackingView(date: date, meal: meal)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .renderingMode(.original)
                                .font(.system(size: 18))
                        }
                    }
                }
            }
            
            if externallyTrackedCalories > 0 {
                HStack {
                    Text("Externally tracked calories")
                    Spacer()
                    Text("\(externallyTrackedCalories)")
                }
            }
        }
    }
}

#Preview {
    DiaryView(date: Date())
}
