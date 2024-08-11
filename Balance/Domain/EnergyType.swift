//
//  EnergyType.swift
//  Balance
//
//  Created by Sabrina Bea on 9/19/23.
//

import Foundation

enum EnergyType: String, CaseIterable {
    case dietary
    case bmr
    case nonexercise
    case exercise
    case tdee
    case net
    
    var basicExplanation: String {
        switch self {
        case .dietary:
            return "**\(Self.dietary.descriptiveName)** is the energy you consume through food and drink."
        case .bmr:
            return "**\(Self.bmr.descriptiveName)** is the energy you use in order to keep yourself alive and perform mandatory bodily functions."
        case .nonexercise:
            return "**\(Self.nonexercise.descriptiveName)** is the energy you burn incidentally during your regular daily activities, like walking around throughout the day, making dinner, etc."
        case .exercise:
            return "**\(Self.exercise.descriptiveName)** is the energy you burn doing intentional exercise."
        case .tdee:
            return "**\(Self.tdee.descriptiveName)** is your total calorie burn for the day."
        case .net:
            return "**\(Self.net.descriptiveName)** are the total energy you consumed minus the total energy you burned."
        }
    }
    
    var extendedExplanation: String {
        switch self {
        case .dietary:
            return "This appears in the Health app as Dietary Energy."
        case .bmr:
            return "It shouldn't vary much day-to-day, but may change drastically over time as your body changes, especially if you experience a signficant change in weight. Since this varies so little day-to-day, we estimate this value for the remainder of the day to help give you a better idea of your total burn for the day, but as a result, you may see it fluctuate slightly throughout the day. This appears in the Health app as Resting Energy, and is what scientific literature refers to as Base Metabolic Rate (BMR)."
        case .nonexercise:
            return "Since this tends to vary from day to day, we try our best to estimate a minimal value for this at the start of the day and let it increase throughout the day as you go about your daily activity. Combined with \(Self.exercise.descriptiveName), this makes up your Active Energy in the Health app. This is a combination of what scientific literature refers to as Non-Exercise Activity Thermogenesis (NEAT) and Thermic Effect of Food (TEF)."
        case .exercise:
            return "We take this to mean any calories burned during a tracked workout. Every day, this value starts out at zero and only gets added in when you do an exercise. Combined with \(Self.nonexercise.descriptiveName), this makes up your Active Energy in the Health app. This is what scientific literature refers to as Exercise Activity Thermogenesis (EAT)."
        case .tdee:
            return "This combines your \(Self.bmr.descriptiveName), \(Self.exercise.descriptiveName), and \(Self.nonexercise.descriptiveName). This is what scientific literature refers to as Total Daily Energy Expenditure (TDEE)."
        case .net:
            return "If this number is positive, you should expect to gain body fat, and if it is negative, you should expect to lose body fat. If it is about zero, you should expect to maintain your current amount of body fat."
        }
    }
    
    var descriptiveName: String {
        switch self {
        case .dietary:
            return "Dietary"
        case .bmr:
            return "Metabolism"
        case .nonexercise:
            return "Non-Exercise Activity"
        case .exercise:
            return "Exercise"
        case .tdee:
            return "Total Burn"
        case .net:
            return "Net Calories"
        }
    }
    
    var shortLabelName: String {
        switch self {
        case .dietary:
            return "Dietary"
        case .bmr:
            return "Metabolism"
        case .nonexercise:
            return "Non-Exercise"
        case .exercise:
            return "Exercise"
        case .tdee:
            return "Total Burn"
        case .net:
            return "Net Calories"
        }
    }
    
    var veryShortLabelName: String {
        switch self {
        case .dietary:
            return "Food"
        case .bmr:
            return "BMR"
        case .nonexercise:
            return "NEAT"
        case .exercise:
            return "Exercise"
        case .tdee:
            return "Total"
        case .net:
            return "Net"
        }
    }
}
