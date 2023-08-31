//
//  GoalDirection.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import Foundation

enum GoalDirection {
    case losing
    case maintaining
    case gaining
    
    static func getDirectionOfGoal(_ goal: Int) -> GoalDirection {
        if goal < 0 {
            return .losing
        }
        
        if goal > 0 {
            return .gaining
        }
        
        return .maintaining
    }
}
