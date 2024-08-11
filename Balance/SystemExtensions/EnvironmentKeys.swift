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
    
    var defaultNeat: Int {
        get { self[DefaultNeatKey.self] }
        set { self[DefaultNeatKey.self] = newValue }
    }
    
    var defaultBmr: Int {
        get { self[DefaultBmrKey.self] }
        set { self[DefaultBmrKey.self] = newValue }
    }
    
    var bmrEstimationMode: BmrEstimationMode {
        get { self[BmrEstimationModeKey.self] }
        set { self[BmrEstimationModeKey.self] = newValue }
    }
    
    var neatEstimationMode: NeatEstimationMode {
        get { self[NeatEstimationModeKey.self] }
        set { self[NeatEstimationModeKey.self] = newValue }
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
struct DefaultNeatKey: EnvironmentKey {
    static let defaultValue: Int = 600
}

// Made public to use defaultValue whenever AppStorage is used directly
struct DefaultBmrKey: EnvironmentKey {
    static let defaultValue: Int = 3000
}

// Made public to use defaultValue whenever AppStorage is used directly
struct BmrEstimationModeKey: EnvironmentKey {
    static let defaultValue = BmrEstimationMode.median
}

// Made public to use defaultValue whenever AppStorage is used directly
struct NeatEstimationModeKey: EnvironmentKey {
    static let defaultValue = NeatEstimationMode.minimum
}

private struct RefreshKey: EnvironmentKey {
    static let defaultValue = PassthroughSubject<Void, Never>()
}
