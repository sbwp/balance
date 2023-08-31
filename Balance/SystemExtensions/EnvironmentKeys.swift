//
//  EnvironmentKeys.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI
import Combine

extension EnvironmentValues {
    var goal: Int {
        get { self[GoalKey.self] }
        set { self[GoalKey.self] = newValue }
    }
    
    var estimationMode: EstimationMode {
        get { self[EstimationModeKey.self] }
        set { self[EstimationModeKey.self] = newValue }
    }
    
    var refresh: PassthroughSubject<Void, Never> {
        get { self[RefreshKey.self] }
        set { self[RefreshKey.self] = newValue }
    }
}

// Made public to use defaultValue whenever AppStorage is used directly
struct GoalKey: EnvironmentKey {
    static let defaultValue: Int = -1500
}

// Made public to use defaultValue whenever AppStorage is used directly
struct EstimationModeKey: EnvironmentKey {
    static let defaultValue = EstimationMode.burnOnly
}

private struct RefreshKey: EnvironmentKey {
    static let defaultValue = PassthroughSubject<Void, Never>()
}
