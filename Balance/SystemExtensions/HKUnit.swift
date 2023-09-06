//
//  HKUnit.swift
//  Balance
//
//  Created by Sabrina Bea on 9/5/23.
//

import HealthKit

extension HKUnit {
    static func bpm() -> HKUnit {
        return count().unitDivided(by: HKUnit.minute())
    }
}
