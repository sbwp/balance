//
//  Pantry.swift
//  Balance
//
//  Created by Sabrina Bea on 6/5/24.
//

import Foundation

@MainActor
class Pantry: ObservableObject {
    @Published var food: [Food]
    @Published var diaryEntries: [DiaryEntry]
    
    var sortedFood: [Food] {
        food.sorted { a, b in
            a.name < b.name
        }
    }
    
    var recentFood: [Food] {
        var map: Dictionary<UUID, Date> = Dictionary()
        
        let entriesByDate = diaryEntries.sorted { a, b in
            if a.date.isSameDayAs(b.date) {
                return a.id < b.id
            }
            return a.date < b.date
        }
        
        for diaryEntry in entriesByDate {
            let date = switch diaryEntry.meal {
            case .breakfast:
                diaryEntry.date.setHour(8)
            case .lunch:
                diaryEntry.date.noon
            case .dinner:
                diaryEntry.date.setHour(18)
            case .snacks:
                diaryEntry.date.setHour(20)
            }
            map.updateValue(date, forKey: diaryEntry.foodId)
        }
        
        return food.sorted { a, b in
            (map[a.id] ?? Date.distantPast) > (map[b.id] ?? Date.distantPast)
        }
    }
    
    var frequentFood: [Food] {
        var map: Dictionary<UUID, Int> = Dictionary()
        
        for diaryEntry in diaryEntries {
            let prevValue = map[diaryEntry.foodId] ?? 0
            map.updateValue(prevValue + 1, forKey: diaryEntry.foodId)
        }
        
        return food.sorted { a, b in
            (map[a.id] ?? 0) > (map[b.id] ?? 0)
        }
    }
    
    init(food: [Food] = [], diaryEntries: [DiaryEntry] = []) {
        self.food = food
        self.diaryEntries = diaryEntries
        
        Task.detached { @MainActor in
            await self.load()
        }
    }
    
    func load() async -> Void {
        self.food = await Endpoint.food.fetch() ?? []
        self.diaryEntries = await Endpoint.diaryEntry.fetch() ?? []
    }
    
    func getMeal(date: Date, meal: Meal) -> [DiaryEntry] {
        return diaryEntries.filter({ $0.meal == meal && $0.date.isSameDayAs(date) }).sorted { a, b in
            a.title < b.title
        }
    }
    
    func search(_ query: String) -> [Food] {
        return food.filter({ $0.name.localizedCaseInsensitiveContains(query) }).sorted { a, b in
            b.name.lowercased() != query.lowercased() && (a.name.lowercased() == query.lowercased() || a.name.lowercased() < b.name.lowercased())
        }
    }
    
    func calories(in diaryEntry: DiaryEntry) -> Int {
        let food = getFoodForDiaryEntry(diaryEntry)
        return food.calories(byWeight: diaryEntry.weightMeasurement, byVolume: diaryEntry.volumeMeasurement)
    }
    
    func calories(on date: Date) -> Int {
        return sumCalories(
            forEntries: diaryEntries.filter({ $0.date.isSameDayAs(date) })
        )
    }
    
    func calories(on date: Date, for meal: Meal) -> Int {
        return sumCalories(
            forEntries: diaryEntries.filter({ $0.date.isSameDayAs(date) && $0.meal == meal })
        )
    }
    
    func sumCalories(forEntries entries: [DiaryEntry]) -> Int {
        return entries.reduce(0) { sum, diaryEntry in
            return sum + diaryEntry.calories
        }
    }
    
    func getFoodForDiaryEntry(_ diaryEntry: DiaryEntry) -> Food {
        return getFoodById(diaryEntry.foodId) ?? Food("Deleted Food", 0, weightMeasurement: Measurement(type: .weight, unit: .gram, amount: 1), volumeMeasurement: Measurement(type: .volume, unit: .milliliter, amount: 1), defaultMeasurement: .weight)
    }
    
    func getFoodById(_ id: UUID) -> Food? {
        return food.first(where: { $0.id == id })
    }
    
    func addOrUpdateFood(_ food: Food) async -> Void {
        _ = await Endpoint.food.put(food)
        if self.food.contains(where: { $0.id == food.id }) {
            self.food.removeAll(where: { $0.id == food.id })
            for diaryEntry in diaryEntries {
                if diaryEntry.foodId == food.id && diaryEntry.title != food.name {
                    await addOrUpdateDiaryEntry(DiaryEntry(renaming: diaryEntry, to: food.name))
                }
            }
        }
        self.food.append(food)
    }
    
    func deleteFood(_ food: Food) async throws -> Void {
        if diaryEntries.contains(where: { $0.foodId == food.id }) {
            throw RuntimeError.withMessage("Cannot delete food because it is in use")
        }
        _ = await Endpoint.food.delete(food)
        self.food.removeAll(where: { $0.id == food.id })
    }
    
    func addOrUpdateDiaryEntry(_ diaryEntry: DiaryEntry) async -> Void {
        _ = await Endpoint.diaryEntry.put(diaryEntry)
        diaryEntries.removeAll(where: { $0.id == diaryEntry.id })
        diaryEntries.append(diaryEntry)
    }
    
    func deleteDiaryEntry(_ diaryEntry: DiaryEntry) async -> Void {
        _ = await Endpoint.diaryEntry.delete(diaryEntry)
        diaryEntries.removeAll(where: { $0.id == diaryEntry.id })
    }
}
