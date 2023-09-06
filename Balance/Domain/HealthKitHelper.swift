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
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
        HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
    ])
    
    private var useFakeData = true
    private var initialized = false
    
    private let fakeActive = 725
    private let fakeResting = 3000
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
    
    public func getActiveEnergy(for dayToQuery: Date, includeEstimated: Bool) async -> Int {
        return await getEnergy(type: .activeEnergyBurned, for: dayToQuery, estimationMethod: includeEstimated ? .neat : .none, placeholder: fakeActive)
    }
    
    public func getRestingEnergy(for dayToQuery: Date, includeEstimated: Bool) async -> Int {
        return await getEnergy(type: .basalEnergyBurned, for: dayToQuery, estimationMethod: includeEstimated ? .median : .none, placeholder: fakeResting)
    }
    
    public func getDietaryEnergy(for dayToQuery: Date, includeEstimated: Bool) async -> Int {
        return await getEnergy(type: .dietaryEnergyConsumed, for: dayToQuery, estimationMethod: includeEstimated ? .median : .none, placeholder: fakeDietary)
    }
    
    public func forceNeatRecalc() {
        UserDefaults.standard.set(Double(0), forKey: "neatLastUpdated")
    }
    
    private func getEnergy(type: HKQuantityTypeIdentifier, for dayToQuery: Date, estimationMethod: EstimationMethod, placeholder: Int) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return placeholder
        }
        
        // Get actual total for requested day
        var result: Double =  await getHealthKitQuantity(type: type, startingFrom: dayToQuery, in: .largeCalorie())
        
        if dayToQuery.isToday {
            switch estimationMethod {
            case .median:
                result += await getMedianForPastDays(type: type, in: .largeCalorie())
            case .neat:
                result += await getNeatForRemainingTime()
            case .none:
                break
            }
        }
        
        return Int(result.rounded())
    }
    
    private func getHealthKitQuantity(type: HKQuantityTypeIdentifier, startingFrom startDateTime: Date, endingAt endDateTimeInput: Date? = nil, in unit: HKUnit) async -> Double {
        let endDateTime = endDateTimeInput ?? startDateTime.endOfDay
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: HKQuantityType(type), predicate: HKQuery.predicateForSamples(withStart: startDateTime, end: endDateTime)),
            options: .cumulativeSum
        )
        
        return (try? await descriptor.result(for: healthStore))?.sumQuantity()?.doubleValue(for: unit) ?? 0
    }
    
    private func get90thPercentileHeartrate(startingFrom startDateTime: Date, endingAt endDateTimeInput: Date) async -> Double {
        let endDateTime = endDateTimeInput
        
        let restingDescriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.restingHeartRate), predicate: HKQuery.predicateForSamples(withStart: startDateTime, end: endDateTime))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        
        guard let results = try? await restingDescriptor.result(for: healthStore) else {
            return await getRestingHeartrate() ?? 50
        }
        
        let resultValues = results.map({ result in result.quantity.doubleValue(for: .bpm()) }).sorted()
        
        return resultValues.count > 0 ? resultValues[(resultValues.count * 9) / 10] : await getRestingHeartrate() ?? 50
    }
    
    private func getRestingHeartrate() async -> Double? {
        let restingDescriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.restingHeartRate))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        
        return (try? await restingDescriptor.result(for: healthStore))?[0].quantity.doubleValue(for: .bpm())
    }
    
    private func getWalkingAverageHeartRate() async -> Double? {
        let walkingDescriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(type: HKQuantityType(.walkingHeartRateAverage))],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )
        
        return (try? await walkingDescriptor.result(for: healthStore))?[0].quantity.doubleValue(for: .bpm())
    }
    
    private func getExerciseHeartrateMinimum() async -> Double {
        let resting = await getRestingHeartrate() ?? 50
        let walking = await getWalkingAverageHeartRate() ?? resting + 40
        
        return resting + ((walking - resting) * 0.8) // 4/5 of the way from resting to walking heart rate
    }
    
    // Look at the 7 days prior to today for the remaining time period, take the lowest value
    private func getMedianForPastDays(type: HKQuantityTypeIdentifier, in unit: HKUnit) async -> Double {
        var values: [Double] = []
        
        for daysToSubtract in 1...7 {
            values.append(await getHealthKitQuantity(type: type, startingFrom: Date().addDays(-daysToSubtract), in: unit))
        }
        
        return values[3]
    }
    
    // Look at the 6 days prior to today for the remaining time period, take the lowest value
    private func getNeatForRemainingTime() async -> Double {
        if (shouldUpdateNeat()) {
            await updateNeatEstimate(in: .largeCalorie())
        }
        
        var estimate: Double = 0
        
        let defaults = UserDefaults.standard
        let now = Date()
        let startHour = now.hour
        let percentRemainingInHour = 1 - (Double(now.minute) / 60)
        
        for hour in (startHour + 1)..<24 {
            estimate += defaults.double(forKey: "neat\(hour)")
        }
        
        let currentHourValue = defaults.double(forKey: "neat\(startHour)")
        estimate += currentHourValue * percentRemainingInHour
        
        return estimate
    }
    
    private func shouldUpdateNeat() -> Bool {
        let defaults = UserDefaults.standard
        let date = Date(timeIntervalSince1970: TimeInterval(defaults.double(forKey: "neatLastUpdated"))) // Date will come back as 1970 if not present, which works here
        return date.distanceInDays(to: Date()) ?? 100 > 7
    }
    
    private func updateNeatEstimate(in unit: HKUnit) async -> Void {
        var calorieData: [Double] = Array(repeating: 0, count: 24)
        var count: [Int] = Array(repeating: 0, count: 24)
        var heartRateUnclampedData: [Double] = Array(repeating: 0, count: 24)
        
        let minHeartRateConsideredExercise = await getExerciseHeartrateMinimum()
        
        for daysToSubtract in 1...7 {
            for hour in 0..<24 {
                let start = Date().addDays(-daysToSubtract).setHour(hour)
                let hourlyValue = await getHealthKitQuantity(type: .activeEnergyBurned, startingFrom: start, endingAt: start.addHours(1), in: unit)
                let hourlyHeartRate = await get90thPercentileHeartrate(startingFrom: start, endingAt: start.addHours(1))
                
                // print("hour: \(hour) \n hourlyValue: \(hourlyValue) \n hourlyHeartRate: \(hourlyHeartRate) \n min: \(minHeartRateConsideredExercise) \n\n\n")
                
                if hourlyHeartRate.isLessThan(minHeartRateConsideredExercise, byDelta: 1) {
                    calorieData[hour] += hourlyValue
                    count[hour] += 1
                }
                
                heartRateUnclampedData[hour] += hourlyValue
            }
        }
        
        let results = calorieData.enumerated().map({ (index, sum) in count[index] > 0 ? sum / Double(count[index]) : 0 })
        
        let defaults = UserDefaults.standard
        defaults.set(Double(Date().timeIntervalSince1970), forKey: "neatLastUpdated")
        for hour in 0..<24 {
            // print("hour: \(hour) \n NEAT: \(results[hour]) \n \n")
            defaults.set(results[hour], forKey: "neat\(hour)")
        }
    }
}

fileprivate enum EstimationMethod {
    case none
    case median
    case neat
}
