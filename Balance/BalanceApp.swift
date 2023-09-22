//
//  BalanceApp.swift
//  Balance
//
//  Created by Sabrina Bea on 8/22/23.
//

import SwiftUI

@main
struct BalanceApp: App {
    @AppStorage("goal") var goal: Int = GoalKey.defaultValue
    @AppStorage("bmrEstimationMode") var bmrEstimationMode: BmrEstimationMode = BmrEstimationModeKey.defaultValue
    @AppStorage("neatEstimationMode") var neatEstimationMode: NeatEstimationMode = NeatEstimationModeKey.defaultValue
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.goal, goal)
                .environment(\.bmrEstimationMode, bmrEstimationMode)
                .environment(\.neatEstimationMode, neatEstimationMode)
        }
    }
}
