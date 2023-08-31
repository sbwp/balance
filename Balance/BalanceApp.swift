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
    @AppStorage("estimationMode") var estimationMode: EstimationMode = EstimationModeKey.defaultValue
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.goal, goal)
                .environment(\.estimationMode, estimationMode)
        }
    }
}
