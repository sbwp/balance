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
        HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
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
        return await getEnergy(type: .activeEnergyBurned, for: dayToQuery, includeEstimated: includeEstimated, placeholder: fakeActive)
    }
    
    public func getRestingEnergy(for dayToQuery: Date, includeEstimated: Bool) async -> Int {
        return await getEnergy(type: .basalEnergyBurned, for: dayToQuery, includeEstimated: includeEstimated, placeholder: fakeResting)
    }
    
    public func getDietaryEnergy(for dayToQuery: Date, includeEstimated: Bool) async -> Int {
        return await getEnergy(type: .dietaryEnergyConsumed, for: dayToQuery, includeEstimated: includeEstimated, placeholder: fakeDietary)
    }
    
    private func getEnergy(type: HKQuantityTypeIdentifier, for dayToQuery: Date, includeEstimated: Bool, placeholder: Int) async -> Int {
        if !initialized {
            await initialize()
        }
        
        if useFakeData {
            return placeholder
        }
        
        // Get actual total for today
        let actualResult: Double =  dayToQuery < Date().endOfDay ? await getHealthKitDailyQuantity(type: type, for: dayToQuery, in: .largeCalorie()) : 0
        
        var estimatedAddition: Double = 0
        
        if includeEstimated && (dayToQuery.isTodayOrFuture || actualResult.approximatelyEquals(0, withinDelta: 1)) {
            // For past dates, try to estimate based on the previous 7 day window prior to the dayToQuery
            if dayToQuery.isYesterdayOrEarlier {
                estimatedAddition = await getSevenDayAverage(type: type, priorTo: dayToQuery.startOfDay, in: .largeCalorie())
            }
            
            // For current/future dates, or if the previous 7 day window had no data, look at the 7 days prior to today (rather than prior to the dayToQuery)
            if dayToQuery.isTodayOrFuture || estimatedAddition.approximatelyEquals(0, withinDelta: 1) {
                let estimateFactor = dayToQuery.isToday ? Date().percentRemainingInDay : 1
                estimatedAddition = await getSevenDayAverage(type: type, priorTo: Date().startOfDay, in: .largeCalorie()) * estimateFactor
            }
        }
        
        return Int((actualResult + estimatedAddition).rounded())
    }
    
    private func getHealthKitDailyQuantity(type: HKQuantityTypeIdentifier, for startOfDay: Date, in unit: HKUnit) async -> Double {
        var interval = DateComponents()
        interval.day = 1
        
        let descriptor = HKStatisticsQueryDescriptor(
            predicate: .quantitySample(type: HKQuantityType(type), predicate: HKQuery.predicateForSamples(withStart: startOfDay, end: startOfDay.endOfDay)),
            options: .cumulativeSum
        )
        
        return (try? await descriptor.result(for: healthStore))?.sumQuantity()?.doubleValue(for: unit) ?? 0
    }
    
    private func getSevenDayAverage(type: HKQuantityTypeIdentifier, priorTo priorToDate: Date, in unit: HKUnit) async -> Double {
        var nonZeroDayCount: Double = 0
        var estimatedAddition: Double = 0
        
        for daysToSubtract in 1...7 {
            let dailyEstimate = await getHealthKitDailyQuantity(type: type, for: priorToDate.addDays(-daysToSubtract), in: .largeCalorie())
            
            if dailyEstimate.isGreaterThan(0, byDelta: 1) {
                estimatedAddition += dailyEstimate
                nonZeroDayCount += 1
            }
        }
        
        if nonZeroDayCount > 0 {
            estimatedAddition /= nonZeroDayCount
        }
        
        return estimatedAddition
    }
}
