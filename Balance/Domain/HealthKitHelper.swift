//
//  HealthKitHelper.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import HealthKit

class HealthKitHelper {
    private static var instance: HealthKitHelper!
    private let healthStore = HKHealthStore()
    
    private let healthStoreWriteTypes = Set<HKSampleType>([])
    private let healthStoreReadTypes = Set([
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!,
        HKObjectType.workoutType()
    ])
    
    private var useFakeData = true
    private var initialized = false
    
    private let energyUnit = HKUnit.largeCalorie()
    private let fakeNonExercise = 725
    private let fakeExercise = 300
    private let fakeBmr = 3000
    private let fakeDietary = 2000
    
    public static func getInstance() -> HealthKitHelper {
        if (instance == nil) {
            instance = HealthKitHelper()
        }
        return instance
    }
    
    private init() {}
    
    private func initialize() async {
        // Enables fake values when in preview mode
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            return
        }
        
        if let _ = try? await healthStore.requestAuthorization(toShare: healthStoreWriteTypes, read: healthStoreReadTypes) {
            useFakeData = false
        }
    }
    
    public func getNonExercise(for dayToQuery: Date, estimationMode: NeatEstimationMode) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return fakeNonExercise
        }
        
        var result = await getEnergy(type: .activeEnergyBurned, for: dayToQuery) - Double(getExercise(for: dayToQuery))
        
        if dayToQuery.isToday && estimationMode != .off {
            result += await getNeatForRemainingTime(estimationMode: estimationMode)
        }
        
        return Int(result.rounded())
    }
    
    public func getExercise(for dayToQuery: Date) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return fakeExercise
        }
        
        return Int(await getWorkoutActiveEnergyTotal(forDay: dayToQuery, in: energyUnit).rounded())
    }
    
    public func getBmr(for dayToQuery: Date, estimationMode: BmrEstimationMode) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return fakeBmr
        }
        
        var result = await getEnergy(type: .basalEnergyBurned, for: dayToQuery)
        
        if dayToQuery.isToday && estimationMode != .off {
            result += await getBmrEstimateForPastDays(estimationMode: estimationMode, in: energyUnit)
        }
        
        return Int(result.rounded())
    }
    
    public func getDietaryEnergy(for dayToQuery: Date) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return fakeDietary
        }
        
        return Int(await getEnergy(type: .dietaryEnergyConsumed, for: dayToQuery).rounded())
    }
    
    public func forceNeatRecalc() {
        UserDefaults.standard.set(Double(0), forKey: "neatLastUpdated")
    }
    
    // TODO: Not necessary, just calls another function with one extra parameter
    private func getEnergy(type: HKQuantityTypeIdentifier, for dayToQuery: Date) async -> Double {
        // Get actual total for requested day
        return await getHealthKitQuantity(type: type, startingFrom: dayToQuery, in: energyUnit)
    }
    
    private func getHealthKitQuantity(type: HKQuantityTypeIdentifier, startingFrom startDateTime: Date, endingAt endDateTimeInput: Date? = nil, in unit: HKUnit) async -> Double {
        let endDateTime = endDateTimeInput ?? startDateTime.endOfDay
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: HKQuantityType(type), predicate: HKQuery.predicateForSamples(withStart: startDateTime, end: endDateTime)),
            options: .cumulativeSum
        )
        
        return (try? await descriptor.result(for: healthStore))?.sumQuantity()?.doubleValue(for: unit) ?? 0
    }
    
    private func getWorkoutActiveEnergyTotal(forDay startDate: Date, in unit: HKUnit) async -> Double {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(HKQuery.predicateForSamples(withStart: startDate, end: startDate.endOfDay))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]
        )
        
        guard let results = try? await descriptor.result(for: healthStore) else {
            return 0
        }
        
        return results
            .map({ $0.statistics(for: HKQuantityType(.activeEnergyBurned))?.sumQuantity()?.doubleValue(for: unit) ?? 0 })
            .reduce(0, { sum, next in sum + next })
    }
    
    private func getWorkoutCount(forHour startDate: Date, in unit: HKUnit) async -> Int {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.workout(HKQuery.predicateForSamples(withStart: startDate, end: startDate.addHours(1)))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)]
        )
        
        guard let results = try? await descriptor.result(for: healthStore) else {
            return 0
        }
        
        return results.count
    }
    
    // Look at the 7 days prior to today for the remaining time period, take the lowest value
    private func getBmrEstimateForPastDays(estimationMode: BmrEstimationMode, in unit: HKUnit) async -> Double {
        var values: [Double] = []
        
        for daysToSubtract in 1...7 {
            values.append(await getHealthKitQuantity(type: .basalEnergyBurned, startingFrom: Date().addDays(-daysToSubtract), in: unit))
        }
        
        values.sort()
        
        let idx = switch estimationMode {
            case .median: 3
            case .minimum: 0
            default: 0
        }
        
        return values[idx]
    }
    
    // Look at the 6 days prior to today for the remaining time period, take the lowest value
    private func getNeatForRemainingTime(estimationMode: NeatEstimationMode) async -> Double {
        var neatForHours: [Double] = []
        switch estimationMode {
            case .minimum:
                neatForHours = await estimateNeatMinimum(in: energyUnit)
            case .mean:
                neatForHours = await estimateNeatMean(in: energyUnit)
            case .off:
                return 0.0
        }
        
        var estimate: Double = 0
        
        let now = Date()
        let startHour = now.hour
        let percentRemainingInHour = 1 - (Double(now.minute) / 60)
        
        for hour in (startHour + 1)..<24 {
            estimate += neatForHours[hour]
        }
        
        let currentHourValue = neatForHours[startHour]
        estimate += currentHourValue * percentRemainingInHour
        
        return estimate
    }
    
    private func estimateNeatMean(in unit: HKUnit) async -> [Double] {
        var calorieData: [Double] = Array(repeating: 0, count: 24)
        var count: [Int] = Array(repeating: 0, count: 24)
        var dataIncludingExercise: [Double] = Array(repeating: 0, count: 24)
        
        for daysToSubtract in 1...7 {
            for hour in 0..<24 {
                let start = Date().addDays(-daysToSubtract).setTime(hour: hour)
                let hourlyValue = await getHealthKitQuantity(type: .activeEnergyBurned, startingFrom: start, endingAt: start.addHours(1), in: unit)
                let didWorkout = await getWorkoutCount(forHour: start, in: unit) > 0
                // TODO: Subtract workout energy instead of excluding if workout? Pro: Get more data, Con: Will capture additional burn from raised heartrate after workout
                                
                if !didWorkout {
                    calorieData[hour] += hourlyValue
                    count[hour] += 1
                }
                
                dataIncludingExercise[hour] += hourlyValue
            }
        }
        
        return calorieData.enumerated().map({ (index, sum) in count[index] > 0 ? sum / Double(count[index]) : 0 })
    }
    
    private func estimateNeatMinimum(in unit: HKUnit) async -> [Double] {
        var calorieData: [Double?] = Array(repeating: nil, count: 24)
        
        for daysToSubtract in 1...7 {
            for hour in 0..<24 {
                let start = Date().addDays(-daysToSubtract).setTime(hour: hour)
                let hourlyValue = await getHealthKitQuantity(type: .activeEnergyBurned, startingFrom: start, endingAt: start.addHours(1), in: unit)
                let didWorkout = await getWorkoutCount(forHour: start, in: unit) > 0
                // TODO: Subtract workout energy instead of excluding if workout? Pro: Get more data, Con: Will capture additional burn from raised heartrate after workout
                                
                if !didWorkout && (calorieData[hour] == nil || calorieData[hour]! > hourlyValue)  {
                    calorieData[hour] = hourlyValue
                }
            }
        }
        
        return calorieData.enumerated().map({ (index, value) in value ?? 0 })
    }
}

fileprivate enum EstimationMethod {
    case none
    case median
    case neat
}
