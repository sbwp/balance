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
    @AppStorage("defaultNeat") var defaultNeat: Int = DefaultNeatKey.defaultValue
    @AppStorage("defaultBmr") var defaultBmr: Int = DefaultBmrKey.defaultValue
    @AppStorage("bmrEstimationMode") var bmrEstimationMode: BmrEstimationMode = BmrEstimationModeKey.defaultValue
    @AppStorage("neatEstimationMode") var neatEstimationMode: NeatEstimationMode = NeatEstimationModeKey.defaultValue
    @StateObject var pantry: Pantry = Pantry()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.goal, goal)
                .environment(\.defaultNeat, defaultNeat)
                .environment(\.defaultBmr, defaultBmr)
                .environment(\.bmrEstimationMode, bmrEstimationMode)
                .environment(\.neatEstimationMode, neatEstimationMode)
                .environmentObject(pantry)
        }
    }
}
