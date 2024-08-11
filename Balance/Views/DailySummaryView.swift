//
//  SummaryView.swift
//  Balance
//
//  Created by Sabrina Bea on 8/31/23.
//

import SwiftUI

struct DailySummaryView: View {
    // Inputs
    var date: Date
    var doCalculation: Bool
    @Binding var displayWeight: Bool
    
    @Environment(\.goal) var goal
    @Environment(\.bmrEstimationMode) var bmrEstimationMode
    @Environment(\.neatEstimationMode) var neatEstimationMode
    @Environment(\.refresh) var refresh
    @EnvironmentObject var pantry: Pantry
    
    @State var exercise: Int = 0
    @State var nonExercise: Int = 0
    @State var resting: Int = 0
    @State var dietary: Int = 0
    
    // Constants
    let hkHelper = HealthKitHelper.getInstance()
    let exerciseColor = Color.green
    let nonExerciseColor = Color.blue
    let restingColor = Color.indigo
    let totalBurnColor = Color.purple
    let dietaryColor = Color.orange
    let circleSize: CGFloat = 150
    
    // Computed values
    var totalBurn: Int { exercise + nonExercise + resting }
    var netCalories: Int { dietary - exercise - nonExercise - resting }
    var netWeightExpected: Double { Double(netCalories) / 3500 }
    var remainingDietaryCalories: Int { goal - netCalories }
    var remainingCaloriesText: String {
        let distance = (goal - netCalories).magnitude
        if distance < 100 {
            return "Good job!"
        }
        
        let direction = GoalDirection.getDirectionOfGoal(goal)
        if netCalories > goal {
            if (direction == .gaining) {
                return "You smashed your goal with \(distance) calories to spare!"
            } else {
                return "You should burn \(distance) more calories to reach your goal."
            }
        } else {
            if (direction == .losing) {
                return "You can eat \(distance) more calories today."
            } else {
                return "You need to eat \(distance) more calories to reach your goal."
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center) {
                ZStack {
                    OpposedStacksCircle(valuesLeft: [dietary], colorsLeft: [dietaryColor], valuesRight: [resting, nonExercise, exercise], colorsRight: [restingColor, nonExerciseColor, exerciseColor])
                    VStack {
                        HStack(alignment: .bottom) {
                            Text(displayWeight ? "\(String(format: "%.1f", netWeightExpected))" : "\(netCalories)")
                                .font(.system(size: circleSize * 0.2, weight: .bold, design: .rounded))
                            Text(displayWeight ? "lb" : "Cal")
                                .font(.system(size: circleSize * 0.08))
                                .padding(.bottom, circleSize * 0.04)
                                .padding(.leading, -circleSize * 0.03)
                        }
                        // Text(displayWeight ? "Expected Weight Change" : "Net Energy")
                        //     .font(.system(size: 10))
                    }
                    .onTapGesture {
                        displayWeight = !displayWeight
                    }
                }
                .frame(width: circleSize, height: circleSize)
                .padding(.vertical, 30)
                .padding(.leading, 30)
                
                VStack {
                    StackedBar(values: [resting, nonExercise, exercise], colors: [restingColor, nonExerciseColor, exerciseColor], maxValue: 6000)
                    HStack(spacing: 4) {
                        Spacer()
                        VStack {
                            Text("\(exercise)")
                            Text(EnergyType.exercise.veryShortLabelName)
                        }
                        .foregroundColor(exerciseColor)
                        .padding(.leading, -5)
                        
                        Text("+")
                            .fontWeight(.bold)
                            .padding(.horizontal, 5)
                        
                        VStack {
                            Text("\(nonExercise)")
                            Text(EnergyType.nonexercise.veryShortLabelName)
                        }
                        .foregroundColor(nonExerciseColor)
                        
                        Text("+")
                            .fontWeight(.bold)
                            .padding(.horizontal, 5)
                        
                        VStack {
                            Text("\(resting)")
                            Text(EnergyType.bmr.veryShortLabelName)
                        }
                        .foregroundColor(restingColor)
                        
                        Text("=")
                            .fontWeight(.bold)
                            .padding(.horizontal, 5)
                        
                        VStack {
                            Text("\(totalBurn)")
                            Text(EnergyType.tdee.veryShortLabelName)
                        }
                        .foregroundColor(totalBurnColor)
                    }
                    // .background(Color.blue)
                    .font(.caption)
                    .padding(.trailing, 5)
                    
                    StackedBar(values: [dietary], colors: [dietaryColor], maxValue: 6000)
                    HStack(spacing: 4) {
                        Spacer()
                        Text("\(dietary) \(EnergyType.dietary.shortLabelName)")
                            .foregroundColor(dietaryColor)
                    }
                    .font(.caption)
                    .padding(.trailing, 5)
                }
            }
            
            if date.isToday {
                Text(remainingCaloriesText)
                    .padding(.bottom)
            }
            
            DiaryView(date: date)
        }
        // .padding(.vertical)
        // .background(.regularMaterial)
        // .cornerRadius(20)
        .onAppear(perform: updateData)
        .onReceive(refresh) {
            if doCalculation {
                updateData()
            }
        }
        .navigationTitle(date.relativeString)
    }
    
    func updateData() {
        Task.detached { @MainActor in
            exercise = await hkHelper.getExercise(for: date)
            nonExercise = await hkHelper.getNonExercise(for: date, estimationMode: neatEstimationMode)
            resting = await hkHelper.getBmr(for: date, estimationMode: bmrEstimationMode)
            // dietary = await hkHelper.getDietaryEnergy(for: date)
            await pantry.load()
            dietary = pantry.calories(on: date)
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        DailySummaryView(date: Date(), doCalculation: true, displayWeight: .constant(false))
    }
}
