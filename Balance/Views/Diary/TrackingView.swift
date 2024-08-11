//
//  TrackingView.swift
//  Balance
//
//  Created by Sabrina Bea on 1/1/24.
//

import SwiftUI

struct TrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @State var searchQuery = ""
    @State var selection: [DiaryEntry] = []
    @State var searchResults: [Food] = []
    @State var foodToAdd: Food? = nil
    @State var isCreateEntryLinkActive: Bool = false
    @State fileprivate var foodListDisplayType: FoodListDisplayType = .frequent
    
    @EnvironmentObject var pantry: Pantry
    
    let date: Date
    let meal: Meal
    
    var foodList: [Food] {
        switch foodListDisplayType {
        case .recent:
            pantry.recentFood
        case .frequent:
            pantry.frequentFood
        case .alphabetical:
            pantry.sortedFood
        }
    }
    
    var body: some View {
        List {
            if selection.count > 0 {
                Section() {
                    ForEach(selection) { diaryEntry in
                        DiaryEntryView(diaryEntry: diaryEntry)
                    }
                } header: {
                    HStack {
                        Text("Selection")
                        Text("(\(pantry.sumCalories(forEntries: selection)))")
                            .opacity(0.6)
                        Spacer()
                    }
                }
            }
                
            TextField("Search", text: $searchQuery)
                .onChange(of: searchQuery) {
                    searchResults = pantry.search(searchQuery)
                }
            
            if searchQuery.count > 0 {
                Section("Search Results") {
                    ForEach(searchResults) { food in
                        FoodResultView(food: food)
                            .fullyTappable()
                            .onTapGesture {
                                foodToAdd = food
                                isCreateEntryLinkActive = true
                            }
                    }
                }
            }
            
            
            Section {
                NavigationLink("Add New Food") {
                    CreateFoodView(name: $searchQuery, createdFood: $foodToAdd)
                        .onAppear {
                            foodToAdd = nil
                        }
                        .onDisappear {
                            if foodToAdd != nil {
                                isCreateEntryLinkActive = true
                            }
                        }
                }
            }
            
            Section("All Foods") {
                Picker("Food List Sort Method", selection: $foodListDisplayType) {
                    ForEach(FoodListDisplayType.allCases, id: \.self) { listType in
                        Text(listType.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                ForEach(foodList) { food in
                    FoodResultView(food: food)
                        .onTapGesture {
                            foodToAdd = food
                            isCreateEntryLinkActive = true
                        }
                }
            }
        }
        .navigationDestination(isPresented: $isCreateEntryLinkActive) {
            if let food = foodToAdd {
                CreateDiaryEntryView(selection: $selection, date: date, meal: meal, food: food)
            }
        }
        .toolbar {
            Button("Save") {
                Task.detached { @MainActor in
                    for diaryEntry in selection {
                        await pantry.addOrUpdateDiaryEntry(diaryEntry)
                    }
                    dismiss()
                }
            }
            .disabled(selection.count == 0)
        }
    }
}

fileprivate enum FoodListDisplayType: String, CaseIterable {
    case recent = "Recent"
    case frequent = "Frequent"
    case alphabetical = "A-Z"
}

#Preview {
    TrackingView(date: Date(), meal: .breakfast)
        .environmentObject(Pantry())
}
